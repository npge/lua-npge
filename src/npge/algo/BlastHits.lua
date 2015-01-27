local makeblastdb = function(bank_fname, consensus_fname)
    local args = {
        'makeblastdb',
        '-dbtype nucl',
        '-out', bank_fname,
        '-in', consensus_fname,
    }
    -- not os.execute to suppress messages produced by blast
    local f = assert(io.popen(table.concat(args, ' ')))
    f:read('*a')
    f:close()
end

local blastn_cmd = function(bank_fname, input, options)
    local config = require 'npge.config'
    local evalue = options.evalue or config.blast.EVALUE
    local workers = options.workers or 1
    local dust = options.dust or config.blast.DUST
    local dust = dust and 'yes' or 'no'
    local args = {
        'blastn',
        '-task blastn',
        '-db', bank_fname,
        '-query', input,
        '-evalue', tostring(evalue),
        '-num_threads', workers,
        '-dust', dust,
    }
    return table.concat(args, ' ')
end

local ori = function(start, stop)
    if start < stop then
        return 1
    else
        return -1
    end
end

local read_blast = function(file, bs, hits_filter)
    local new_blocks = {}
    local query, subject
    local query_row, subject_row
    local query_start, subject_start
    local query_stop, subject_stop
    local good_hit = function()
        return query and subject and query < subject and
            query_row and subject_row
    end
    local try_add = function()
        if good_hit() then
            assert(query_row)
            assert(subject_row)
            assert(query_start)
            assert(query_stop)
            assert(subject_start)
            assert(subject_stop)
            local Fragment = require 'npge.model.Fragment'
            local query_seq = bs:sequence_by_name(query)
            assert(query_seq)
            local query_ori = ori(query_start, query_stop)
            local query_f = Fragment(query_seq,
                query_start - 1, query_stop - 1, query_ori)
            local subject_seq = bs:sequence_by_name(subject)
            assert(subject_seq)
            local subject_ori = ori(subject_start, subject_stop)
            local subject_f = Fragment(subject_seq,
                subject_start - 1, subject_stop - 1,
                subject_ori)
            local Block = require 'npge.model.Block'
            local query_row1 = table.concat(query_row)
            local subject_row1 = table.concat(subject_row)
            local block = Block({
                {query_f, query_row1},
                {subject_f, subject_row1},
            })
            if not hits_filter or hits_filter(block) then
                table.insert(new_blocks, block)
            end
        end
        query_row = nil
        subject_row = nil
        query_start = nil
        query_stop = nil
        subject_start = nil
        subject_stop = nil
    end
    local starts_with = require 'npge.util.starts_with'
    local split = require 'npge.util.split'
    local trim = require 'npge.util.trim'
    local unpack = require 'npge.util.unpack'
    local file_is_empty = true
    for line in file:lines() do
        file_is_empty = false
        if starts_with(line, 'Query=') then
            -- Example: Query= consensus000567
            try_add()
            query = split(line, '=', 1)[2]
            query = trim(query)
            query = split(query)[1]
        elseif line:sub(1, 1) == '>' then
            -- Example: > consensus000567
            try_add()
            subject = trim(line:sub(2))
            subject = split(subject)[1]
        elseif starts_with(line, ' Score =') then
            -- Example:  Score = 82.4 bits (90),  ...
            try_add()
            query_row = {}
            subject_row = {}
        elseif good_hit() then
            local parse_alignment = function(line)
                local parts = split(line)
                assert(#parts == 4 or #parts == 3)
                if #parts == 4 then
                    local _, start, row, stop = unpack(parts)
                    return start, row, stop
                end
                if #parts == 3 then
                    local _, row = unpack(parts)
                    return nil, row, nil
                end
            end
            if starts_with(line, 'Query ') then
                -- Example: Query  1  GCGCG  5
                local start, row, stop = parse_alignment(line)
                if start and stop then
                    if not query_start then
                        query_start = assert(tonumber(start))
                    end
                    query_stop = assert(tonumber(stop))
                end
                table.insert(query_row, row)
            elseif starts_with(line, 'Sbjct ') then
                -- Example: Sbjct  1  GCGCG  5
                local start, row, stop = parse_alignment(line)
                if start and stop then
                    if not subject_start then
                        subject_start = assert(tonumber(start))
                    end
                    subject_stop = assert(tonumber(stop))
                end
                table.insert(subject_row, row)
            end
        end
    end
    try_add()
    assert(not file_is_empty, "blastn returned empty file")
    local BlockSet = require 'npge.model.BlockSet'
    return BlockSet(bs:sequences(), new_blocks)
end

return function(blockset, options)
    -- possible options:
    -- - evalue
    -- - dust
    -- - workers
    -- - hits_filter
    --   (filtering function, accepts hit, returns true/false)
    options = options or {}
    local algo = require 'npge.algo'
    local util = require 'npge.util'
    if #blockset:sequences() == 0 then
        assert(#blockset:blocks() == 0)
        local BlockSet = require 'npge.model.BlockSet'
        return BlockSet({}, {})
    end
    local consensus_fname = os.tmpname()
    util.write_it(consensus_fname,
        algo.WriteSequencesToFasta(blockset))
    local bank_fname = os.tmpname()
    makeblastdb(bank_fname, consensus_fname)
    assert(util.file_exists(bank_fname .. '.nhr'))
    local cmd = blastn_cmd(bank_fname, consensus_fname, options)
    local f = assert(io.popen(cmd, 'r'))
    local hits = read_blast(f, blockset, options.hits_filter)
    f:close()
    os.remove(consensus_fname)
    os.remove(bank_fname)
    os.remove(bank_fname .. '.nhr')
    os.remove(bank_fname .. '.nin')
    os.remove(bank_fname .. '.nsq')
    return hits
end
