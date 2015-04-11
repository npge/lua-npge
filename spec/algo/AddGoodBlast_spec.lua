-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

describe("npge.algo.AddGoodBlast", function()
    it("finds hits using blast+ on blocks", function()
        local Sequence = require 'npge.model.Sequence'
        local s1 = Sequence('s1', string.rep('ATGC', 100))
        local s2 = Sequence('s2', string.rep('ATGC', 100))
        local BlockSet = require 'npge.model.BlockSet'
        local bs_with_seqs = BlockSet({s1, s2}, {})
        local Cover = require 'npge.algo.Cover'
        local bs_with_blocks = Cover(bs_with_seqs)
        local AddGoodBlast = require 'npge.algo.AddGoodBlast'
        local hits = AddGoodBlast(bs_with_blocks,
            bs_with_blocks)
        assert.truthy(#hits:blocks() > 0)
    end)

    it("finds hits using blast+ on blocks (different bank)",
    function()
        local Sequence = require 'npge.model.Sequence'
        local s1 = Sequence('s1', string.rep('ATGC', 100))
        local s2 = Sequence('s2', string.rep('ATGC', 100))
        local BlockSet = require 'npge.model.BlockSet'
        local Cover = require 'npge.algo.Cover'
        local query = Cover(BlockSet({s1}, {}))
        local bank = Cover(BlockSet({s2}, {}))
        local AddGoodBlast = require 'npge.algo.AddGoodBlast'
        local hits = AddGoodBlast(query, bank)
        assert.truthy(#hits:blocks() > 0)
    end)

    it("finds blast hits (different bank, shared sequence)",
    function()
        local Sequence = require 'npge.model.Sequence'
        local s1 = Sequence('s1', string.rep('ATGC', 100))
        local s2 = Sequence('s2', string.rep('ATGC', 100))
        local s3 = Sequence('s3', string.rep('ATGC', 100))
        local BlockSet = require 'npge.model.BlockSet'
        local Cover = require 'npge.algo.Cover'
        local query = Cover(BlockSet({s1, s2}, {}))
        local bank = Cover(BlockSet({s2, s3}, {}))
        local AddGoodBlast = require 'npge.algo.AddGoodBlast'
        local hits = AddGoodBlast(query, bank)
        assert.truthy(#hits:blocks() > 0)
    end)

    it("finds nothing if no blocks", function()
        local Sequence = require 'npge.model.Sequence'
        local s1 = Sequence('s1', string.rep('ATGC', 100))
        local s2 = Sequence('s2', string.rep('ATGC', 100))
        local BlockSet = require 'npge.model.BlockSet'
        local bs_with_seqs = BlockSet({s1, s2}, {})
        local AddGoodBlast = require 'npge.algo.AddGoodBlast'
        local hits = AddGoodBlast(bs_with_seqs, bs_with_seqs)
        assert.equal(#hits:blocks(), 0)
    end)

    it("finds if query is a subset of bank", function()
        local m = require 'npge.model'
        local s1 = m.Sequence('s1', string.rep('ATGC', 100))
        local b1 = m.Block({m.Fragment(s1, 0, 100, 1)})
        local b2 = m.Block({m.Fragment(s1, 200, 101, -1)})
        local query = m.BlockSet({s1}, {b1})
        local bank = m.BlockSet({s1}, {b1, b2})
        local AddGoodBlast = require 'npge.algo.AddGoodBlast'
        local hits = AddGoodBlast(query, bank, {subset=1})
        assert.truthy(#hits:blocks() >= 1)
    end)

    it("throws if query isn't bank subset, but declared to",
    function()
        local m = require 'npge.model'
        local s1 = m.Sequence('s1', string.rep('ATGC', 100))
        local b1 = m.Block({m.Fragment(s1, 0, 100, 1)})
        local b2 = m.Block({m.Fragment(s1, 200, 101, -1)})
        local query = m.BlockSet({s1}, {b1})
        local bank = m.BlockSet({s1}, {b2})
        local AddGoodBlast = require 'npge.algo.AddGoodBlast'
        assert.has_error(function()
            local hits = AddGoodBlast(query, bank, {subset=1})
        end)
    end)
end)
