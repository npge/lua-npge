-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

describe("npge.algo.FilterGoodBlocks", function()
    it("returns blockset of good blocks", function()
        -- one block is good and the other one is bad
        -- insert non-identical columns in the middle of block
        local Sequence = require 'npge.model.Sequence'
        local config = require 'npge.config'
        local min_ident = config.general.MIN_IDENTITY
        local length = 1000
        -- bad block
        local good_cols = math.floor(length * min_ident) - 1
        local bad_cols = length - good_cols
        local first_good_part = math.floor(good_cols / 2)
        local second_good_part = good_cols - first_good_part
        local s1 = Sequence('s1', string.rep('A', length))
        local s2 = Sequence('s2',
            string.rep('A', first_good_part) ..
            string.rep('C', bad_cols) ..
            string.rep('A', second_good_part))
        local Fragment = require 'npge.model.Fragment'
        local f1 = Fragment(s1, 0, length - 1, 1)
        local f2 = Fragment(s2, 0, length - 1, 1)
        local Block = require 'npge.model.Block'
        local bad_block = Block({f1, f2})
        -- bad block
        local good_cols = math.floor(length * min_ident) + 1
        local bad_cols = length - good_cols
        local first_good_part = math.floor(good_cols / 2)
        local second_good_part = good_cols - first_good_part
        local s3 = Sequence('s3', string.rep('A', length))
        local s4 = Sequence('s4',
            string.rep('A', first_good_part) ..
            string.rep('C', bad_cols) ..
            string.rep('A', second_good_part))
        local Fragment = require 'npge.model.Fragment'
        local f3 = Fragment(s3, 0, length - 1, 1)
        local f4 = Fragment(s4, 0, length - 1, 1)
        local Block = require 'npge.model.Block'
        local good_block = Block({f3, f4})
        --
        local BlockSet = require 'npge.model.BlockSet'
        local blockset = BlockSet({s1, s2, s3, s4},
            {good_block, bad_block})
        --
        local FilterGoodBlocks =
            require 'npge.algo.FilterGoodBlocks'
        local bs1 = FilterGoodBlocks(blockset)
        assert.equal(bs1, BlockSet({s1, s2, s3, s4},
            {good_block}))
    end)
end)
