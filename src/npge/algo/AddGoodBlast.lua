-- Options are same as options of BlastHits
-- Additional options:
--  - subset (query is a subset of subject)
return function(query, bank, options)
    options = options or {}
    local algo = require 'npge.algo'
    local bank_cons, seq2block =
        algo.ConsensusSequences(bank, 'bank')
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
        for block in query:iter_blocks() do
            local seq = assert(b2s[block])
            table.insert(query_seqs, seq)
        end
        local BlockSet = require 'npge.model.BlockSet'
        query_cons = BlockSet(query_seqs, {})
    else
        local query_s2b
        query_cons, query_s2b =
            algo.ConsensusSequences(query, 'query')
        for seq, block in pairs(query_s2b) do
            seq2block[seq] = block
        end
        blockset = algo.Merge(query, bank)
    end
    local hits_cons = algo.BlastHits(query_cons, bank_cons,
        options)
    hits_cons = algo.Cover(hits_cons)
    local hits = algo.UnwindBlocks(hits_cons,
        blockset, seq2block)
    hits = algo.GoodSubblocks(hits)
    return hits
end
