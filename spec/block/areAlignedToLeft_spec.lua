-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

describe("npge.block.areAlignedToLeft", function()
    it("returns if there is no base after a gap in block",
    function()
        local areLeft = require 'npge.block.areAlignedToLeft'
        local m = require 'npge.model'
        local s = m.Sequence("s", "ATAT")
        local f = m.Fragment(s, 0, 3, 1) -- ATAT
        assert.truthy(areLeft(m.Block{f}))
        assert.truthy(areLeft(m.Block{
            {f, "ATAT"},
        }))
        assert.truthy(areLeft(m.Block{
            {f, "ATAT-"},
            {f, "ATAT-"},
        }))
        assert.truthy(areLeft(m.Block{
            {f, "ATAT--"},
            {f, "ATAT--"},
        }))
        --
        assert.falsy(areLeft(m.Block{
            {f, "-ATAT---"},
            {f, "ATAT----"},
            {f, "ATAT----"},
            {f, "ATAT----"},
            {f, "ATAT----"},
        }))
        assert.falsy(areLeft(m.Block{
            {f, "AT-AT-"},
            {f, "AT-AT-"},
        }))
    end)
end)
