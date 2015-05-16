-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

describe("npge.block.better", function()
    it("select larger block", function()
        local model = require 'npge.model'
        local s = model.Sequence("s", "ATAT")
        local f1 = model.Fragment(s, 0, 0, 1)
        local f2 = model.Fragment(s, 1, 1, 1)
        local f3 = model.Fragment(s, 0, 1, 1)
        local B = model.Block
        local better = require 'npge.block.better'
        assert.truthy(better(B{f1, f2}, B{f1}))
        assert.truthy(better(B{f1, f2}, B{f2}))
        assert.falsy(better(B{f1}, B{f1}))
        assert.falsy(better(B{f1, f2}, B{f1, f2}))
        assert.truthy(better(B{f1, f2}, B{f3}))
        assert.truthy(better(B{f3}, B{f1}))
        assert.truthy(better(B{f3}, B{f2}))
    end)
end)
