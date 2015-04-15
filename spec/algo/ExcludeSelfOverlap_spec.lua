-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

describe("npge.algo.ExcludeSelfOverlap", function()
    it("makes a blockset without self-overlaps", function()
        local model = require 'npge.model'
        local a = model.Sequence("a&chr1&c", "ATGC")
        local b = model.Sequence("b&chr1&c", "ATGC")
        local a_0_1_dir = model.Fragment(a, 0, 1, 1)
        local b_0_1_dir = model.Fragment(b, 0, 1, 1)
        local eso = require 'npge.algo.ExcludeSelfOverlap'
        local Block = model.Block
        local BlockSet = model.BlockSet
        local bs = BlockSet({a, b}, {
            Block {a_0_1_dir, b_0_1_dir},
        })
        assert.same(eso(bs), bs)
    end)
end)
