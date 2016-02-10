-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2016 Boris Nagaev
-- See the LICENSE file for terms of use.

-- Options are same as options of BlastHits
return function(query, bank, options)
    options = options or {}
    local prefix2blockset = {}
    local algo = require 'npge.algo'
    local CS = algo.ConsensusSequences
    local bank_cons = CS(bank, 'bank-')
    prefix2blockset['bank-'] = bank
    local query_cons
    if query == bank then
        query_cons = bank_cons
    elseif options.subset then
        local query_seqs = {}
        for block, block_name in query:iterBlocks() do
            local bank_block = bank:blockByName(block_name)
            assert(block == assert(bank_block))
            local name = 'bank-' .. block_name
            local seq = assert(bank_cons:sequenceByName(name))
            table.insert(query_seqs, seq)
        end
        local BlockSet = require 'npge.model.BlockSet'
        query_cons = BlockSet(query_seqs, {})
    else
        query_cons = CS(query, 'query-')
        prefix2blockset['query-'] = query
    end
    local hits_cons = algo.Workers.BlastHits(
        query_cons, bank_cons, options)
    hits_cons = algo.ExcludeSelfOverlap(hits_cons)
    hits_cons = algo.Cover(hits_cons)
    local hits = algo.UnwindBlocks(hits_cons,
        prefix2blockset)
    hits = algo.Workers.GoodSubblocks(hits)
    return hits
end
