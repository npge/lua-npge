-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

describe("npge.fragment.fragment_to_sequence", function()
    it("converts position in fragment to sequence", function()
        local model = require 'npge.model'
        local s = model.Sequence("test_name", "AATA")
        local f = model.Fragment(s, 0, 3, 1)
        local fs = require 'npge.fragment.fragment_to_sequence'
        assert.equal(fs(f, 0), 0)
        assert.equal(fs(f, 1), 1)
        assert.equal(fs(f, 2), 2)
        assert.equal(fs(f, 3), 3)
        assert.has_error(function()
            fs(f, -1)
        end)
        assert.has_error(function()
            fs(f, 4)
        end)
    end)

    it("converts position in fragment to sequence (parted)",
    function()
        local model = require 'npge.model'
        local s = model.Sequence("g&c&c", "AATA")
        local f = model.Fragment(s, 1, 2, -1)
        local fs = require 'npge.fragment.fragment_to_sequence'
        assert.equal(fs(f, 0), 1)
        assert.equal(fs(f, 1), 0)
        assert.equal(fs(f, 2), 3)
        assert.equal(fs(f, 3), 2)
        assert.has_error(function()
            fs(f, -1)
        end)
        assert.has_error(function()
            fs(f, 4)
        end)
    end)
end)
