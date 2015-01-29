return function(blockset, options)
    local algo = require 'npge.algo'
    local consensuses, seq2block =
        algo.ConsensusSequences(blockset, 'query')
    local orig_bank = options and options.bank
    if orig_bank then
        local s2b
        options.bank, s2b = algo.ConsensusSequences(orig_bank,
            'bank')
        for seq, block in pairs(s2b) do
            seq2block[seq] = block
        end
        blockset = algo.Merge(blockset, orig_bank)
    end
    local hits_cons = algo.BlastHits(consensuses, options)
    hits_cons = algo.Cover(hits_cons)
    local hits = algo.UnwindBlocks(hits_cons,
        blockset, seq2block)
    hits = algo.GoodSubblocks(hits)
    return hits
end
