-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

describe("npge.algo.Workers", function()
    it("extracts good blocks in parallel",
    function()
        local config = require 'npge.config'
        local revert = config:updateKeys({
            util = {WORKERS = 4},
        })
        local min_len = config.general.MIN_LENGTH
        local good_len = 2 * min_len
        local min_ident = config.general.MIN_IDENTITY
        -- ident = good_len / (good_len + middle_len)
        local middle_len = good_len / min_ident - good_len
        middle_len = math.floor(middle_len) + 2
        local length = good_len + middle_len
        local Sequence = require 'npge.model.Sequence'
        local s1 = Sequence('s1', string.rep('A', length))
        local s2 = Sequence('s2',
            string.rep('A', min_len) ..
            string.rep('T', middle_len) ..
            string.rep('A', min_len))
        local Fragment = require 'npge.model.Fragment'
        local f1 = Fragment(s1, 0, s1:length() - 1, 1)
        local f2 = Fragment(s2, 0, s2:length() - 1, 1)
        local Block = require 'npge.model.Block'
        local blocks = {}
        local N = 1000
        for i = 1, N do
            local block = Block({f1, f2})
            table.insert(blocks, block)
        end
        local BlockSet = require 'npge.model.BlockSet'
        local blockset = BlockSet({s1, s2}, blocks)
        --
        local Workers = require 'npge.algo.Workers'
        local good_blocks = Workers.GoodSubblocks(blockset)
        assert.truthy(#good_blocks:blocks() >= N)
        local isGood = require 'npge.block.isGood'
        assert.truthy(isGood(good_blocks:blocks()[1]))
        --
        revert()
    end)

    it("works if number of workers is 1",
    function()
        local config = require 'npge.config'
        local revert = config:updateKeys({
            util = {WORKERS = 1},
        })
        --
        local BlockSet = require 'npge.model.BlockSet'
        local blockset = BlockSet({}, {})
        --
        local Workers = require 'npge.algo.Workers'
        local good_blocks = Workers.GoodSubblocks(blockset)
        assert.equal(#good_blocks:blocks(), 0)
        --
        revert()
    end)

    it("returns the same blocks",
    function()
        local config = require 'npge.config'
        local revert = config:updateKeys({
            util = {WORKERS = 4},
        })
        --
        local model = require 'npge.model'
        local BlockSet = model.BlockSet
        local s1 = model.Sequence('s1', 'ACTG')
        local s2 = model.Sequence('s2', 'CTG')
        local b1 = model.Block({
            model.Fragment(s1, 1, 1, 1),
        })
        local b2 = model.Block({
            model.Fragment(s1, 2, 2, 1),
        })
        local blockset = BlockSet({s1, s2}, {b1, b2})
        --
        local Workers = require 'npge.algo.Workers'
        local bs = Workers.applyToBlockset(blockset,
            "return ...", Workers.mapBlocks)
        assert.equal(bs, blockset)
        --
        revert()
    end)

    it("returns the same sequences", function()
        local config = require 'npge.config'
        local revert = config:updateKeys({
            util = {WORKERS = 4},
        })
        --
        local model = require 'npge.model'
        local BlockSet = model.BlockSet
        local s1 = model.Sequence('s1', 'ACTG')
        local s2 = model.Sequence('s2', 'CTG')
        local s3 = model.Sequence('s3', 'CTG')
        local s4 = model.Sequence('s4', 'CTG')
        local blockset = BlockSet({s1, s2, s3, s4}, {})
        --
        local Workers = require 'npge.algo.Workers'
        local bs = Workers.applyToBlockset(blockset,
            "return ...", Workers.mapSequences)
        assert.equal(bs, blockset)
        --
        revert()
    end)

    it("covers sequences", function()
        local config = require 'npge.config'
        local revert = config:updateKeys({
            util = {WORKERS = 4},
        })
        --
        local model = require 'npge.model'
        local BlockSet = model.BlockSet
        local s1 = model.Sequence('s1', 'ACTG')
        local s2 = model.Sequence('s2', 'CTG')
        local s3 = model.Sequence('s3', 'CTG')
        local s4 = model.Sequence('s4', 'CTG')
        local blockset = BlockSet({s1, s2, s3, s4}, {})
        --
        local Workers = require 'npge.algo.Workers'
        local bs = Workers.applyToBlockset(blockset, [[
            local Cover = require 'npge.algo.Cover'
            return Cover(...)
            ]], Workers.mapSequences)
        local Cover = require 'npge.algo.Cover'
        assert.equal(bs, Cover(blockset))
        --
        revert()
    end)

    it("catches errors thrown in threads",
    function()
        local config = require 'npge.config'
        local revert = config:updateKeys({
            util = {WORKERS = 4},
        })
        --
        local model = require 'npge.model'
        local BlockSet = model.BlockSet
        local s1 = model.Sequence('s1', 'ACTG')
        local s2 = model.Sequence('s2', 'CTG')
        local b1 = model.Block({
            model.Fragment(s1, 1, 1, 1),
        })
        local b2 = model.Block({
            model.Fragment(s1, 2, 2, 1),
        })
        local blockset = BlockSet({s1, s2}, {b1, b2})
        --
        local Workers = require 'npge.algo.Workers'
        assert.has_error(function()
            Workers.applyToBlockset(blockset,
                "error('test')", Workers.mapBlocks)
        end)
        --
        revert()
    end)
end)
