-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

describe("block.align", function()
    it("align block", function()
        local config = require 'npge.config'
        local clone = require 'npge.util.clone'.dict
        local orig = clone(config.alignment)
        config.alignment.MISMATCH_CHECK = 1
        config.alignment.GAP_CHECK = 1
        --
        local model = require 'npge.model'
        local s1 = model.Sequence('s1', "ATGCTTGCTATTTAATGC")
        local s2 = model.Sequence('s2', "ATGCATGC")
        local f1 = model.Fragment(s1, 0, s1:length() - 1, 1)
        local f2 = model.Fragment(s2, 0, s2:length() - 1, 1)
        local block = model.Block({f1, f2})
        --
        local align = require 'npge.block.align'
        local block_aligned = align(block)
        assert.equal(block_aligned,
            model.Block({
                {f1, "ATGCTTGCTATTTAATGC"},
                {f2, "ATGC----------ATGC"},
        }))
        --
        config.alignment = orig
    end)

    it("align block of 1 fragment", function()
        local model = require 'npge.model'
        local s1 = model.Sequence('s1', "ATG")
        local f1 = model.Fragment(s1, 0, s1:length() - 1, 1)
        local block = model.Block({f1})
        --
        local align = require 'npge.block.align'
        local block_aligned = align(block)
        assert.equal(block_aligned,
            model.Block({
                {f1, "ATG"},
        }))
    end)
end)
