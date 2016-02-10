-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2016 Boris Nagaev
-- See the LICENSE file for terms of use.

describe("npge.block.hasSelfOverlap", function()
    it("detects self-overlapping blocks", function()
        local model = require 'npge.model'
        local a = model.Sequence("a&chr1&c", "ATGC")
        local b = model.Sequence("b&chr1&c", "ATGC")
        local a_0_1_dir = model.Fragment(a, 0, 1, 1)
        local a_1_0_rev = model.Fragment(a, 1, 0, -1)
        local a_2_2_dir = model.Fragment(a, 2, 2, 1)
        local a_3_1_dir = model.Fragment(a, 3, 1, 1) -- parted
        local a_1_2_dir = model.Fragment(a, 1, 2, 1)
        local b_0_1_dir = model.Fragment(b, 0, 1, 1)
        local b_1_1_dir = model.Fragment(b, 1, 1, 1)
        local hso = require 'npge.block.hasSelfOverlap'
        local Block = model.Block
        assert.truthy(hso(Block {a_0_1_dir, a_1_0_rev}))
        assert.falsy(hso(Block {a_0_1_dir, a_2_2_dir}))
        assert.falsy(hso(Block {a_3_1_dir, a_2_2_dir}))
        assert.truthy(hso(Block {a_3_1_dir, a_0_1_dir}))
        assert.truthy(hso(Block {a_3_1_dir, a_1_0_rev}))
        assert.falsy(hso(Block {a_0_1_dir, b_0_1_dir}))
        assert.truthy(hso(Block {a_0_1_dir,
            b_1_1_dir, a_1_2_dir}))
    end)
end)
