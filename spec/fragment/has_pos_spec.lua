-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

describe("fragment.has_pos", function()
    it("checks if fragment has sequence index", function()
        local model = require 'npge.model'
        local has_pos = require 'npge.fragment.has_pos'
        local s = model.Sequence("genome&chromosome&c", "ATGC")
        local f = model.Fragment(s, 3, 1, 1)
        assert.is.truthy(has_pos(f, 3))
        assert.is.truthy(has_pos(f, 0))
        assert.is.truthy(has_pos(f, 1))
        assert.is.falsy(has_pos(f, 2))
        local f = model.Fragment(s, 1, 3, -1)
        assert.is.truthy(has_pos(f, 3))
        assert.is.truthy(has_pos(f, 0))
        assert.is.truthy(has_pos(f, 1))
        assert.is.falsy(has_pos(f, 2))
    end)
end)
