-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2016 Boris Nagaev
-- See the LICENSE file for terms of use.

-- short form = consensuses + mutations
-- short form is sufficient to recover full form

describe("npge.alignment.consensus", function()
    it("calculates consensus of equal sequences", function()
        local consensus = require 'npge.alignment.consensus'
        assert.equal(consensus({
            "ATGC",
            "ATGC",
        }), "ATGC")
    end)

    it("preferres more frequent base", function()
        local consensus = require 'npge.alignment.consensus'
        assert.equal(consensus({
            "A",
            "T",
            "T",
        }), "T")
    end)

    it("any base overcomes gap", function()
        local consensus = require 'npge.alignment.consensus'
        assert.equal(consensus({
            "A",
            "-",
            "-",
        }), "A")
        assert.equal(consensus({
            "N",
            "-",
            "-",
        }), "N")
    end)

    it("bases A, T, G, C overcome preudo-base N", function()
        local consensus = require 'npge.alignment.consensus'
        assert.equal(consensus({
            "A",
            "N",
            "N",
        }), "A")
    end)

    it("returns N for pure-gap columns", function()
        local consensus = require 'npge.alignment.consensus'
        assert.equal(consensus({
            "-",
            "-",
            "-",
        }), "N")
    end)

    it("throws if called without table argument", function()
        local consensus = require 'npge.alignment.consensus'
        assert.has_error(function()
            consensus()
        end)
        assert.has_error(function()
            consensus(1)
        end)
        assert.has_error(function()
            consensus("A")
        end)
    end)

    it("returns nil if called with empty table", function()
        local consensus = require 'npge.alignment.consensus'
        assert.falsy(consensus({}))
    end)

    it("returns empty string if alignment length is 0",
    function()
        local consensus = require 'npge.alignment.consensus'
        assert.equal(consensus({""}), "")
        assert.equal(consensus({"", ""}), "")
    end)
end)
