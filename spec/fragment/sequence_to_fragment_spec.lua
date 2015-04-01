-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

describe("fragment.sequence_to_fragment", function()
    it("converts position in sequence to fragment", function()
        local model = require 'npge.model'
        local s = model.Sequence("test_name", "AATA")
        local f = model.Fragment(s, 0, 3, 1)
        local sf = require 'npge.fragment.sequence_to_fragment'
        assert.equal(sf(f, 0), 0)
        assert.equal(sf(f, 1), 1)
        assert.equal(sf(f, 2), 2)
        assert.equal(sf(f, 3), 3)
        assert.has_error(function()
            sf(f, -1)
        end)
        assert.has_error(function()
            sf(f, 4)
        end)
    end)

    it("converts position in sequence to fragment (reversed)",
    function()
        local model = require 'npge.model'
        local s = model.Sequence("test_name", "AATA")
        local f = model.Fragment(s, 3, 0, -1)
        local sf = require 'npge.fragment.sequence_to_fragment'
        assert.equal(sf(f, 0), 3)
        assert.equal(sf(f, 1), 2)
        assert.equal(sf(f, 2), 1)
        assert.equal(sf(f, 3), 0)
        assert.has_error(function()
            sf(f, -1)
        end)
        assert.has_error(function()
            sf(f, 4)
        end)
    end)

    it("converts position in sequence to fragment (shifted)",
    function()
        local model = require 'npge.model'
        local s = model.Sequence("test_name", "AATA")
        local f = model.Fragment(s, 1, 2, 1)
        local sf = require 'npge.fragment.sequence_to_fragment'
        assert.equal(sf(f, 1), 0)
        assert.equal(sf(f, 2), 1)
        assert.has_error(function()
            sf(f, -1)
        end)
        assert.has_error(function()
            sf(f, 0)
        end)
        assert.has_error(function()
            sf(f, 3)
        end)
        assert.has_error(function()
            sf(f, 4)
        end)
    end)

    it("converts position in sequence to fragment (parted)",
    function()
        local model = require 'npge.model'
        local s = model.Sequence("g&c&c", "AATA")
        local f = model.Fragment(s, 2, 1, 1)
        local sf = require 'npge.fragment.sequence_to_fragment'
        assert.equal(sf(f, 0), 2)
        assert.equal(sf(f, 1), 3)
        assert.equal(sf(f, 2), 0)
        assert.equal(sf(f, 3), 1)
        assert.has_error(function()
            sf(f, -1)
        end)
        assert.has_error(function()
            sf(f, 4)
        end)
    end)

    it("converts pos. in sequence to fragment (parted, rev)",
    function()
        local model = require 'npge.model'
        local s = model.Sequence("g&c&c", "AATA")
        local f = model.Fragment(s, 1, 2, -1)
        local sf = require 'npge.fragment.sequence_to_fragment'
        assert.equal(sf(f, 0), 1)
        assert.equal(sf(f, 1), 0)
        assert.equal(sf(f, 2), 3)
        assert.equal(sf(f, 3), 2)
        assert.has_error(function()
            sf(f, -1)
        end)
        assert.has_error(function()
            sf(f, 4)
        end)
    end)
end)
