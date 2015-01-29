describe("algo.AddGoodBlast", function()
    it("finds hits using blast+ on blocks", function()
        local Sequence = require 'npge.model.Sequence'
        local s1 = Sequence('s1', string.rep('ATGC', 100))
        local s2 = Sequence('s2', string.rep('ATGC', 100))
        local BlockSet = require 'npge.model.BlockSet'
        local bs_with_seqs = BlockSet({s1, s2}, {})
        local Cover = require 'npge.algo.Cover'
        local bs_with_blocks = Cover(bs_with_seqs)
        local AddGoodBlast = require 'npge.algo.AddGoodBlast'
        local hits = AddGoodBlast(bs_with_blocks)
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
        local hits = AddGoodBlast(query, {bank=bank})
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
        local hits = AddGoodBlast(query, {bank=bank})
        assert.truthy(#hits:blocks() > 0)
    end)

    it("finds nothing if no blocks", function()
        local Sequence = require 'npge.model.Sequence'
        local s1 = Sequence('s1', string.rep('ATGC', 100))
        local s2 = Sequence('s2', string.rep('ATGC', 100))
        local BlockSet = require 'npge.model.BlockSet'
        local bs_with_seqs = BlockSet({s1, s2}, {})
        local AddGoodBlast = require 'npge.algo.AddGoodBlast'
        local hits = AddGoodBlast(bs_with_seqs)
        assert.equal(#hits:blocks(), 0)
    end)
end)
