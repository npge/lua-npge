-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

describe("npge.alignment.refine", function()
    it("does nothing if alignment if good", function()
        local refine = require 'npge.alignment.refine'
        assert.same(refine({}), {})
        assert.same(refine({""}), {""})
        assert.same(refine({"", ""}), {"", ""})
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
        assert.same(refine({
            "ATGCTTGCTATTTAATGC",
            "ATGC----------ATGC",
        }), {
            "ATGCTTGCTATTTAATGC",
            "ATGC----------ATGC",
        })
    end)

    it("throws if the argument is nil", function()
        local refine = require 'npge.alignment.refine'
        assert.has_error(function()
            refine()
        end)
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

    it("moves base A to make good column", function()
        local refine = require 'npge.alignment.refine'
        local rows = refine({
            "AATTCAGG-ATCAAAAAT",
            "AATTCAGGA-TCAAAAAT",
            "AATTCACGAATCGAAAAT",
        })
        assert.truthy(rows[1] == "AATTCAGGA-TCAAAAAT" or
            rows[2] == "AATTCAGG-ATCAAAAAT")
    end)

    it("moves base A to make good column (2 vs 2)",
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

    it("moves a base over gaps", function()
        local refine = require 'npge.alignment.refine'
        assert.same(refine({
            "AAACCCCTTTTT",
            "AAAT----TTTT",
        }), {
            "AAACCCCTTTTT",
            "AAA----TTTTT",
        })
        assert.same(refine({
            "AAA----TTTTT",
            "AAAT----TTTT",
        }), {
            "AAATTTTT",
            "AAATTTTT",
        })
        assert.same(refine({
            "AAAC---TTTTT",
            "AAAT----TTTT",
        }), {
            "AAACTTTTT",
            "AAA-TTTTT",
        })
        assert.same(refine({
            "AAACCCCTTTTT",
            "AA----ATTTTT",
        }), {
            "AAACCCCTTTTT",
            "AAA----TTTTT",
        })
        assert.same(refine({
            "AAA----TTTTT",
            "AA----ATTTTT",
        }), {
            "AAATTTTT",
            "AAATTTTT",
        })
        assert.same(refine({
            "AAA---CTTTTT",
            "AA----ATTTTT",
        }), {
            "AAACTTTTT",
            "AAA-TTTTT",
        })
    end)

    it("moves a base over group of equal bases", function()
        local refine = require 'npge.alignment.refine'
        assert.same(refine({
            "AAACCCC-",
            "AAAGCCCC",
        }), {
            "AAA-CCCC",
            "AAAGCCCC",
        })
        assert.same(refine({
            "AAACCCCG",
            "AAA-CCCC",
        }), {
            "AAACCCCG",
            "AAACCCC-",
        })
        assert.same(refine({
            "AAACCCC-TT",
            "AAAGCCCCTT",
        }), {
            "AAA-CCCCTT",
            "AAAGCCCCTT",
        })
        assert.same(refine({
            "AAACCCCGTT",
            "AAA-CCCCTT",
        }), {
            "AAACCCCGTT",
            "AAACCCC-TT",
        })
    end)

    it("moves even if number of bases in sorce if higher",
    function()
        local refine = require 'npge.alignment.refine'
        assert.same(refine({
            "AAACCCC-",
            "AAACCCC-",
            "AAACCCC-",
            "AAAGCCCC",
        }), {
            "AAA-CCCC",
            "AAA-CCCC",
            "AAA-CCCC",
            "AAAGCCCC",
        })
        assert.same(refine({
            "AAACCCCTTTTT",
            "AA----ATTTTT",
            "AA----ATTTTT",
            "AA----ATTTTT",
        }), {
            "AAACCCCTTTTT",
            "AAA----TTTTT",
            "AAA----TTTTT",
            "AAA----TTTTT",
        })
    end)

    it("applies multiple refinements", function()
        local refine = require 'npge.alignment.refine'
        assert.same(refine({
            "AAACCCC-TTAAA",
            "AAACCCC-TTAAA",
            "AAAGCCCCT---T",
        }), {
            "AAA-CCCCTTAAA",
            "AAA-CCCCTTAAA",
            "AAAGCCCCTT---",
        })
    end)
end)
