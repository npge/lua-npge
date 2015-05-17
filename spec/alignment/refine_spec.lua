-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

describe("npge.alignment.refine", function()
    it("does nothing if alignment if good", function()
        local refine = require 'npge.alignment.refine'
        assert.same(refine({}), {})
        assert.same(refine({"ATGC"}), {"ATGC"})
        assert.same(refine({
            "AATTCAGGA-TCAAAAAT",
            "AATTCAGGA-TCAAAAAT",
            "AATTCACGAATCGAAAAT",
        }), {
            "AATTCAGGA-TCAAAAAT",
            "AATTCAGGA-TCAAAAAT",
            "AATTCACGAATCGAAAAT",
        })
        assert.same(refine({
            "AATTCAGG-ATCAAAAAT",
            "AATTCAGG-ATCAAAAAT",
            "AATTCACGAATCGAAAAT",
        }), {
            "AATTCAGG-ATCAAAAAT",
            "AATTCAGG-ATCAAAAAT",
            "AATTCACGAATCGAAAAT",
        })
    end)

    it("moves base A to make good column", function()
        local refine = require 'npge.alignment.refine'
        assert.same(refine({
            "AATTCAGG-ATCAAAAAT",
            "AATTCAGGA-TCAAAAAT",
            "AATTCACGTATCGAAAAT",
        }), {
            "AATTCAGG-ATCAAAAAT",
            "AATTCAGG-ATCAAAAAT",
            "AATTCACGTATCGAAAAT",
        })
    end)

    pending("moves base A to make good column", function()
        local refine = require 'npge.alignment.refine'
        local rows = refine({
            "AATTCAGG-ATCAAAAAT",
            "AATTCAGGA-TCAAAAAT",
            "AATTCACGAATCGAAAAT",
        })
        assert.truthy(rows[1] == "AATTCAGGA-TCAAAAAT" or
            rows[2] == "AATTCAGG-ATCAAAAAT")
    end)

    pending("moves base A to make good column (2 vs 2)",
    function()
        local refine = require 'npge.alignment.refine'
        assert.same(refine({
            "AATTCAGG-ATCAAAAAT",
            "AATTCAGG-ATCAAAAAT",
            "AATTCAGGA-TCAAAAAT",
            "AATTCACGA-TCGAAAAT",
        }), {
            "AATTCAGGATCAAAAAT",
            "AATTCAGGATCAAAAAT",
            "AATTCAGGATCAAAAAT",
            "AATTCACGATCGAAAAT",
        })
    end)

    it("removes gaps", function()
        local refine = require 'npge.alignment.refine'
        assert.same(refine({
            "AATTCAGG--ATCAAAAAT",
            "AATTCAGG--ATCAAAAAT",
            "AATTCACGA-ATCGAAAAT",
        }), {
            "AATTCAGG-ATCAAAAAT",
            "AATTCAGG-ATCAAAAAT",
            "AATTCACGAATCGAAAAT",
        })
    end)
end)
