-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

describe("npge.block.alignLeft", function()
    it("align block to left", function()
        local model = require 'npge.model'
        local s1 = model.Sequence('s1', "ATG")
        local s2 = model.Sequence('s2', "A-G")
        local f1 = model.Fragment(s1, 0, s1:length() - 1, 1)
        local f2 = model.Fragment(s2, 0, s2:length() - 1, 1)
        local block = model.Block({
            {f1, 'ATG'},
            {f2, 'A-G'},
        })
        --
        local alignLeft = require 'npge.block.alignLeft'
        local block_aligned = alignLeft(block)
        assert.equal(block_aligned, model.Block({f1, f2}))
    end)
end)
