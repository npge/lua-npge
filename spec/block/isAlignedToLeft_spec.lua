-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2016 Boris Nagaev
-- See the LICENSE file for terms of use.

describe("npge.block.isAlignedToLeft", function()
    it("returns if there is no base after a gap", function()
        local iatl = require 'npge.block.isAlignedToLeft'
        local m = require 'npge.model'
        local s = m.Sequence("s", "ATAT")
        local f = m.Fragment(s, 0, 3, 1) -- ATAT
        assert.truthy(iatl(f, m.Block{f}))
        assert.truthy(iatl(f, m.Block{
            {f, "ATAT"},
        }))
        assert.truthy(iatl(f, m.Block{
            {f, "ATAT-"},
        }))
        assert.truthy(iatl(f, m.Block{
            {f, "ATAT--"},
        }))
        assert.truthy(iatl(f, m.Block{
            {f, "ATAT----"},
        }))
        --
        assert.falsy(iatl(f, m.Block{
            {f, "-ATAT"},
        }))
        assert.falsy(iatl(f, m.Block{
            {f, "AT-AT-"},
        }))
        assert.falsy(iatl(f, m.Block{
            {f, "A-TAT--"},
        }))
        assert.falsy(iatl(f, m.Block{
            {f, "ATA-T----"},
        }))
    end)
end)
