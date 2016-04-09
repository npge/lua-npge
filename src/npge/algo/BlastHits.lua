-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2016 Boris Nagaev
-- See the LICENSE file for terms of use.

local ori = function(start, stop)
    if start < stop then
        return 1
    else
        return -1
    end
end

local function readBlast(file, query, bank, same, line_handler)
    local new_blocks = {}
    local query_name, bank_name
    local query_row, bank_row
    local query_start, bank_start
    local query_stop, bank_stop
    local function goodHit()
        return query_name and bank_name
            and query_row and bank_row
    end
    local function goodFragments(_, _)
        return true
    end
    if same then
        local goodHit0 = goodHit
        goodHit = function()
            return goodHit0() and query_name <= bank_name
        end
        goodFragments = function(query_f, bank_f)
            return query_f < bank_f
        end
    end
    local function tryAdd()
        if goodHit() then
            assert(query_row)
            assert(bank_row)
            assert(query_start)
            assert(query_stop)
            assert(bank_start)
            assert(bank_stop)
            local Fragment = require 'npge.model.Fragment'
            local query_seq = query:sequenceByName(query_name)
            assert(query_seq)
            local query_ori = ori(query_start, query_stop)
            local query_f = Fragment(query_seq,
                query_start - 1, query_stop - 1, query_ori)
            local bank_seq = bank:sequenceByName(bank_name)
            assert(bank_seq)
            local bank_ori = ori(bank_start, bank_stop)
            local bank_f = Fragment(bank_seq,
                bank_start - 1, bank_stop - 1, bank_ori)
            if goodFragments(query_f, bank_f) then
                local Block = require 'npge.model.Block'
                local query_row1 = table.concat(query_row)
                local bank_row1 = table.concat(bank_row)
                local block = Block({
                    {query_f, query_row1},
                    {bank_f, bank_row1},
                })
                table.insert(new_blocks, block)
            end
        end
        query_row = nil
        bank_row = nil
        query_start = nil
        query_stop = nil
        bank_start = nil
        bank_stop = nil
    end
    local startsWith = require 'npge.util.startsWith'
    local split = require 'npge.util.split'
    local trim = require 'npge.util.trim'
    local unpack = require 'npge.util.unpack'
    local file_is_empty = true
    for line in file:lines() do
        line = trim(line)
        if line_handler then
            line_handler(line)
        end
        file_is_empty = false
        if startsWith(line, 'Query=') then
            -- Example: Query= consensus000567
            tryAdd()
            query_name = split(line, '=', 1)[2]
            query_name = trim(query_name)
            query_name = split(query_name)[1]
        elseif line:sub(1, 1) == '>' then
            -- Example: > consensus000567
            tryAdd()
            bank_name = trim(line:sub(2))
            bank_name = split(bank_name)[1]
        elseif startsWith(line, 'Score =') then
            -- Example:  Score = 82.4 bits (90),  ...
            tryAdd()
            query_row = {}
            bank_row = {}
        elseif goodHit() then
            local function parseAlignment(line1)
                local parts = split(line1)
                assert(#parts == 4 or #parts == 2)
                if #parts == 4 then
                    local _, start, row, stop = unpack(parts)
                    return start, row, stop
                end
                if #parts == 2 then
                    local _, row = unpack(parts)
                    return nil, row, nil
                end
            end
            if startsWith(line, 'Query ') then
                -- Example: Query  1  GCGCG  5
                local start, row, stop = parseAlignment(line)
                if start and stop then
                    if not query_start then
                        query_start = assert(tonumber(start))
                    end
                    query_stop = assert(tonumber(stop))
                end
                table.insert(query_row, row)
            elseif startsWith(line, 'Sbjct ') then
                -- Example: Sbjct  1  GCGCG  5
                local start, row, stop = parseAlignment(line)
                if start and stop then
                    if not bank_start then
                        bank_start = assert(tonumber(start))
                    end
                    bank_stop = assert(tonumber(stop))
                end
                table.insert(bank_row, row)
            end
        end
    end
    tryAdd()
    assert(not file_is_empty, "blastn returned empty file")
    local seqs = bank:sequences()
    if not same then
        for seq in query:iterSequences() do
            if not bank:sequenceByName(seq:name()) then
                table.insert(seqs, seq)
            end
        end
    end
    local BlockSet = require 'npge.model.BlockSet'
    return BlockSet(seqs, new_blocks)
end

return function(query, bank, options)
    -- possible options:
    -- - bank_fname - pre-built bank
    -- - subset - if truthy, then query is interpreted as
    --   a subset of bank. All hits where query > bank
    --   are discarded (optimisation). They are compared
    --   as instances of Fragment.
    -- - line_handler - a function that is called with
    --   each line of blast output
    local Blast = require 'npge.algo.Blast'
    local tmpName = require 'npge.util.tmpName'
    options = options or {}
    local BlockSet = require 'npge.model.BlockSet'
    if #query:sequences() == 0 or #bank:sequences() == 0 then
        return BlockSet({}, {})
    end
    Blast.checkNoCollisions(query, bank)
    local same = (query == bank)
    local bank_cons_fname, bank_fname
    if options.bank_fname then
        bank_fname = options.bank_fname
    else
        bank_cons_fname = tmpName()
        Blast.makeConsensus(bank_cons_fname, bank)
        bank_fname = tmpName()
        Blast.makeBlastDb(bank_fname, bank_cons_fname)
    end
    local query_cons_fname
    if same and bank_cons_fname then
        query_cons_fname = bank_cons_fname
    else
        query_cons_fname = tmpName()
        Blast.makeConsensus(query_cons_fname, query)
    end
    --
    local cmd = Blast.blastnCmd(bank_fname,
        query_cons_fname, options)
    local f = assert(io.popen(cmd, 'r'))
    local hits = readBlast(f, query, bank,
        same or options.subset, options.line_handler)
    f:close()
    if bank_cons_fname then
        os.remove(bank_cons_fname)
    end
    if query_cons_fname then
        os.remove(query_cons_fname)
    end
    if not options.bank_fname then
        Blast.bankCleanup(bank_fname)
    end
    return hits
end
