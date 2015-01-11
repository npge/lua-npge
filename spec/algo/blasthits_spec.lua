describe("algo.BlastHits", function()
    it("finds hits using blast+", function()
        local Sequence = require 'npge.model.Sequence'
        local s1 = Sequence('s1', string.rep('ATGC', 100))
        local s2 = Sequence('s2', string.rep('ATGC', 100))
        local BlockSet = require 'npge.model.BlockSet'
        local bs_with_seqs = BlockSet({s1, s2}, {})
        local BlastHits = require 'npge.algo.BlastHits'
        local hits = BlastHits(bs_with_seqs)
        assert.truthy(#hits:blocks() > 0)
    end)

    it("finds hits using blast+ (set evalue)", function()
        local Sequence = require 'npge.model.Sequence'
        local s1 = Sequence('s1', string.rep('ATGC', 100))
        local s2 = Sequence('s2', string.rep('ATGC', 100))
        local BlockSet = require 'npge.model.BlockSet'
        local bs_with_seqs = BlockSet({s1, s2}, {})
        local BlastHits = require 'npge.algo.BlastHits'
        local hits = BlastHits(bs_with_seqs, 0.01)
        assert.truthy(#hits:blocks() > 0)
    end)
end)
