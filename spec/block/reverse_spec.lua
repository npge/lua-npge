-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

describe("npge.block.reverse", function()
    it("reverses block", function()
        local model = require 'npge.model'
        local s = model.Sequence("test_name", "AATAT")
        local f1 = model.Fragment(s, 0, 2, 1) -- AAT
        local f2 = model.Fragment(s, 4, 3, -1) -- AT
        local block = model.Block({
            {f1, 'AAT'},
            {f2, 'A-T'},
        })
        local reverse = require 'npge.block.reverse'
        local block_rev = reverse(block)
        local block_rev_exp = model.Block({
            {model.Fragment(s, 2, 0, -1), 'ATT'},
            {model.Fragment(s, 3, 4, 1), 'A-T'},
        })
        assert.are.equal(block_rev, block_rev_exp)
        assert.not_equal(block_rev, block)
    end)
end)
