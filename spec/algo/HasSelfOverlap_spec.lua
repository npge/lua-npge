-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2016 Boris Nagaev
-- See the LICENSE file for terms of use.

describe("npge.algo.HasSelfOverlap", function()
    it("detects self-overlapping blocks", function()
        local model = require 'npge.model'
        local a = model.Sequence("a&chr1&c", "ATGC")
        local b = model.Sequence("b&chr1&c", "ATGC")
        local a_0_1_dir = model.Fragment(a, 0, 1, 1)
        local a_1_0_rev = model.Fragment(a, 1, 0, -1)
        local b_0_1_dir = model.Fragment(b, 0, 1, 1)
        local hso = require 'npge.algo.HasSelfOverlap'
        local Block = model.Block
        local BlockSet = model.BlockSet
        assert.truthy(hso(BlockSet({a}, {
            Block {a_0_1_dir, a_1_0_rev},
        })))
        assert.falsy(hso(BlockSet({a, b}, {
            Block {a_0_1_dir, b_0_1_dir},
        })))
        assert.truthy(hso(BlockSet({a}, {
            Block {a_0_1_dir, a_1_0_rev},
            Block {a_0_1_dir, a_1_0_rev},
        })))
    end)
end)
