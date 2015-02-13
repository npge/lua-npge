local ori = function(start, stop)
    if start < stop then
        return 1
    else
        return -1
    end
end

local read_blast = function(file, query, bank, filter, same)
    local new_blocks = {}
    local query_name, subject_name
    local query_row, subject_row
    local query_start, subject_start
    local query_stop, subject_stop
    local good_hit = function()
        return query_name and subject_name
            and query_row and subject_row
    end
    if same then
        local good_hit0 = good_hit
        good_hit = function()
            return good_hit0() and query_name < subject_name
        end
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
            local query_seq =
                query:sequence_by_name(query_name)
            assert(query_seq)
            local query_ori = ori(query_start, query_stop)
            local query_f = Fragment(query_seq,
                query_start - 1, query_stop - 1, query_ori)
            local subject_seq =
                bank:sequence_by_name(subject_name)
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
            if not filter or filter(block) then
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
            query_name = split(line, '=', 1)[2]
            query_name = trim(query_name)
            query_name = split(query_name)[1]
        elseif line:sub(1, 1) == '>' then
            -- Example: > consensus000567
            try_add()
            subject_name = trim(line:sub(2))
            subject_name = split(subject_name)[1]
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
    local seqs = query:sequences()
    if not same then
        for seq in bank:iter_sequences() do
            if not query:sequence_by_name(seq:name()) then
                table.insert(seqs, seq)
            end
        end
    end
    local BlockSet = require 'npge.model.BlockSet'
    return BlockSet(seqs, new_blocks)
end

return function(query, bank, options)
    -- possible options:
    -- - evalue
    -- - dust
    -- - workers
    -- - hits_filter
    --   (filtering function, accepts hit, returns true/false)
    local Blast = require 'npge.algo.Blast'
    options = options or {}
    local BlockSet = require 'npge.model.BlockSet'
    if #query:sequences() == 0 or #bank:sequences() == 0 then
        return BlockSet({}, {})
    end
    Blast.checkNoCollisions(query, bank)
    local same = (query == bank)
    local bank_cons_fname = os.tmpname()
    Blast.makeConsensus(bank_cons_fname, bank)
    local query_cons_fname
    if same then
        query_cons_fname = bank_cons_fname
    else
        query_cons_fname = os.tmpname()
        Blast.makeConsensus(query_cons_fname, query)
    end
    local bank_fname = os.tmpname()
    Blast.makeBlastDb(bank_fname, bank_cons_fname)
    local cmd = Blast.blastnCmd(bank_fname,
        query_cons_fname, options)
    local f = assert(io.popen(cmd, 'r'))
    local filter = options.hits_filter
    local hits = read_blast(f, query, bank, filter, same)
    f:close()
    os.remove(bank_cons_fname)
    if not same then
        os.remove(query_cons_fname)
    end
    Blast.bankCleanup(bank_fname)
    return hits
end
