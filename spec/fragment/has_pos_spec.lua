-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

describe("npge.fragment.hasPos", function()
    it("checks if fragment has sequence index", function()
        local model = require 'npge.model'
        local hasPos = require 'npge.fragment.hasPos'
        local s = model.Sequence("genome&chromosome&c", "ATGC")
        local f = model.Fragment(s, 3, 1, 1)
        assert.is.truthy(hasPos(f, 3))
        assert.is.truthy(hasPos(f, 0))
        assert.is.truthy(hasPos(f, 1))
        assert.is.falsy(hasPos(f, 2))
        local f = model.Fragment(s, 1, 3, -1)
        assert.is.truthy(hasPos(f, 3))
        assert.is.truthy(hasPos(f, 0))
        assert.is.truthy(hasPos(f, 1))
        assert.is.falsy(hasPos(f, 2))
    end)
end)
