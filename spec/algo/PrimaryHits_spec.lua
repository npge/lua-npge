-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

describe("npge.algo.PrimaryHits", function()
    it("finds hits using blast+ combining groups of sequences",
    function()
        local Sequence = require 'npge.model.Sequence'
        local s1 = Sequence('s1', string.rep('ATGC', 100))
        local s2 = Sequence('s2', string.rep('ATGC', 100))
        local s3 = Sequence('s3', string.rep('ATGC', 100))
        local s4 = Sequence('s4', string.rep('ATGC', 100))
        local BlockSet = require 'npge.model.BlockSet'
        local bs_with_seqs = BlockSet({s1, s2, s3, s4}, {})
        local PrimaryHits = require 'npge.algo.PrimaryHits'
        local hits = PrimaryHits(bs_with_seqs)
        assert.truthy(#hits:blocks() > 0)
        local max_size = 0
        for block in hits:iterBlocks() do
            max_size = math.max(max_size, block:size())
        end
        assert.truthy(max_size >= 4)
    end)

    it("finds hits using blast+ combining groups of genomes",
    function()
        local Sequence = require 'npge.model.Sequence'
        local s1 = Sequence('g1&c1&c', string.rep('ATGC', 100))
        local s2 = Sequence('g1&c2&c', string.rep('CCAA', 100))
        local s3 = Sequence('g2&c1&c', string.rep('ATGC', 100))
        local s4 = Sequence('g2&c2&c', string.rep('CCAA', 100))
        local BlockSet = require 'npge.model.BlockSet'
        local bs_with_seqs = BlockSet({s1, s2, s3, s4}, {})
        local PrimaryHits = require 'npge.algo.PrimaryHits'
        local hits = PrimaryHits(bs_with_seqs)
        assert.truthy(#hits:blocks() > 0)
        local max_size = 0
        for block in hits:iterBlocks() do
            max_size = math.max(max_size, block:size())
        end
        assert.truthy(max_size >= 2)
    end)
end)
