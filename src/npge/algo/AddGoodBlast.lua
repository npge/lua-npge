return function(query, bank, options)
    local algo = require 'npge.algo'
    local query_cons, seq2block =
        algo.ConsensusSequences(query, 'query')
    local s2b
    local bank_cons, blockset
    if query == bank then
        bank_cons = query_cons
        blockset = query
    else
        local bank_s2b
        bank_cons, bank_s2b =
            algo.ConsensusSequences(bank, 'bank')
        for seq, block in pairs(bank_s2b) do
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
