-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

-- Options are same as options of BlastHits
return function(query, bank, options)
    options = options or {}
    local algo = require 'npge.algo'
    local CS = algo.ConsensusSequences
    local bank_cons, seq2block = CS(bank, 'bank')
    local s2b
    local query_cons, blockset
    if query == bank then
        query_cons = bank_cons
        blockset = bank
    elseif options.subset then
        blockset = bank
        local b2s = {}
        for seq, block in pairs(seq2block) do
            b2s[block] = seq
        end
        local query_seqs = {}
        for block in query:iterBlocks() do
            local seq = assert(b2s[block])
            table.insert(query_seqs, seq)
        end
        local BlockSet = require 'npge.model.BlockSet'
        query_cons = BlockSet(query_seqs, {})
    else
        local query_s2b
        query_cons, query_s2b = CS(query, 'query')
        for seq, block in pairs(query_s2b) do
            seq2block[seq] = block
        end
        blockset = algo.Merge(query, bank)
    end
    local hits_cons = algo.Workers.BlastHits(
        query_cons, bank_cons, options)
    hits_cons = algo.ExcludeSelfOverlap(hits_cons)
    hits_cons = algo.Cover(hits_cons)
    local hits = algo.UnwindBlocks(hits_cons,
        blockset, seq2block)
    hits = algo.Workers.GoodSubblocks(hits)
    return hits
end
