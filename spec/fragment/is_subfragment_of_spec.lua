-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

describe("fragment.is_subfragment_of", function()
    it("#is_subfragment", function()
        local model = require 'npge.model'
        local s = model.Sequence("genome&chromosome&c", "ATGC")
        local f = model.Fragment(s, 3, 1, 1)
        local iso = require 'npge.fragment.is_subfragment_of'
        assert.is.truthy(iso(model.Fragment(s, 3, 1, 1), f))
        assert.is.truthy(iso(model.Fragment(s, 3, 0, 1), f))
        assert.is.falsy(iso(model.Fragment(s, 2, 2, 1), f))
        assert.is.falsy(iso(model.Fragment(s, 1, 3, 1), f))
    end)

    it("#is_subfragment whole sequence", function()
        local model = require 'npge.model'
        local s = model.Sequence("genome&chromosome&c", "ATGC")
        local f = model.Fragment(s, 3, 2, 1)
        local iso = require 'npge.fragment.is_subfragment_of'
        assert.is.truthy(iso(model.Fragment(s, 0, 3, 1), f))
        assert.is.truthy(iso(model.Fragment(s, 2, 1, 1), f))
        assert.is.truthy(iso(model.Fragment(s, 2, 0, 1), f))
        assert.is.truthy(iso(model.Fragment(s, 2, 0, -1), f))
    end)

    it("#is_subfragment source parted", function()
        local model = require 'npge.model'
        local s = model.Sequence("genome&chromosome&c", "ATGC")
        local f = model.Fragment(s, 3, 0, 1)
        local iso = require 'npge.fragment.is_subfragment_of'
        assert.is.falsy(iso(model.Fragment(s, 0, 3, 1), f))
        assert.is.truthy(iso(model.Fragment(s, 0, 3, -1), f))
    end)

    it("#is_subfragment self parted", function()
        local model = require 'npge.model'
        local s = model.Sequence("genome&chromosome&c", "ATGC")
        local f = model.Fragment(s, 1, 3, 1)
        local iso = require 'npge.fragment.is_subfragment_of'
        assert.is.falsy(iso(model.Fragment(s, 1, 3, -1), f))
    end)
end)
