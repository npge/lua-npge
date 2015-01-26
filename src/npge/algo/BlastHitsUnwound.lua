return function(blockset)
    local algo = require 'npge.algo'
    local consensuses, seq2block =
        algo.ConsensusSequences(blockset)
    local hits_cons = algo.BlastHits(consensuses)
    hits_cons = algo.Cover(hits_cons)
    local hits = algo.UnwindBlocks(hits_cons,
        blockset, seq2block)
    hits = algo.GoodSubblocks(hits)
    return hits
end
