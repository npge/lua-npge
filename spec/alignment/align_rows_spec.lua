-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

describe("npge.alignment.alignRows", function()
    it("align multiple rows (simple)", function()
        local f = require 'npge.alignment.alignRows'
        assert.same(f({"ATGC"}), {"ATGC"})
    end)

    it("align multiple rows (2 equal sequences)", function()
        local f = require 'npge.alignment.alignRows'
        assert.same(f({
            "ATGC",
            "ATGC",
        }), {
            "ATGC",
            "ATGC",
        })
    end)

    it("align multiple rows (long gap)", function()
        local config = require 'npge.config'
        local revert = config:updateKeys({
            alignment = {
                MISMATCH_CHECK = 1,
                GAP_CHECK = 1,
                ANCHOR = 4,
            },
        })
        --
        local f = require 'npge.alignment.alignRows'
        assert.same(f({
            "ATGCTTTTTTTTTATGC",
            "ATGCATGC",
        }), {
            "ATGCTTTTTTTTTATGC",
            "ATGC---------ATGC",
        })
        --
        revert()
    end)

    it("align multiple rows (long gap, 4 rows)", function()
        local config = require 'npge.config'
        local revert = config:updateKeys({
            alignment = {
                MISMATCH_CHECK = 1,
                GAP_CHECK = 1,
                ANCHOR = 4,
            },
        })
        --
        local f = require 'npge.alignment.alignRows'
        assert.same(f({
            "ATGCTTATTATTTAATGC",
            "ATGCTTTTTATTTAATGC",
            "ATGCTTTTTTTTAATGC",
            "ATGCATGC",
        }), {
            "ATGCTTATTATTTAATGC",
            "ATGCTTTTTATTTAATGC",
            "ATGCTTTTT-TTTAATGC",
            "ATGC----------ATGC",
        })
        --
        revert()
    end)

    it("align multiple rows (long gap, 4 rows, empty row)",
    function()
        local config = require 'npge.config'
        local revert = config:updateKeys({
            alignment = {
                MISMATCH_CHECK = 1,
                GAP_CHECK = 1,
                ANCHOR = 4,
            },
        })
        --
        local f = require 'npge.alignment.alignRows'
        assert.same(f({
            "ATGCTTATTATTTAATGC",
            "ATGCTTTTTATTTAATGC",
            "ATGCTTTTTTTTAATGC",
            "ATGCATGC",
            "",
        }), {
            "ATGCTTATTATTTAATGC",
            "ATGCTTTTTATTTAATGC",
            "ATGCTTTTT-TTTAATGC",
            "ATGC----------ATGC",
            "------------------",
        })
        --
        revert()
    end)

    it("align multiple rows (long gap, #4_rows, double)",
    function()
        local config = require 'npge.config'
        local revert = config:updateKeys({
            alignment = {
                MISMATCH_CHECK = 1,
                GAP_CHECK = 2,
                ANCHOR = 4,
            },
        })
        --
        local f = require 'npge.alignment.alignRows'
        assert.same(f({
            "ATGCTCCTTATTTAATGCATTTATTCCTATGC",
            "ATGCTCCTTATTTAATGCATTTATTCCTATGC",
            "ATGCTCCTTTTTAATGCATTTTTCCTATGC",
            "ATGCATGCATGC",
        }), {
            "ATGCTCCTTATTTAATGCATTTATTCCTATGC",
            "ATGCTCCTTATTTAATGCATTTATTCCTATGC",
            "ATGCTCCTT-TTTAATGCATTT-TTCCTATGC",
            "ATGC----------ATGC----------ATGC",
        })
        --
        revert()
    end)

    it("align multiple rows (#only_left)", function()
        local config = require 'npge.config'
        local revert = config:updateKeys({
            alignment = {
                MISMATCH_CHECK = 1,
                GAP_CHECK = 1,
            },
        })
        --
        local f = require 'npge.alignment.alignRows'
        assert.same(f({
            "ATGCTTGCTATTTAATGC",
            "ATGCATGC",
        }, true), {
            "ATGCTTGCTATTTAATGC",
            "ATGCATGC----------",
        })
        --
        revert()
    end)

    it("align multiple rows (#only_left control)", function()
        local config = require 'npge.config'
        local revert = config:updateKeys({
            alignment = {
                MISMATCH_CHECK = 1,
                GAP_CHECK = 1,
            },
        })
        --
        local f = require 'npge.alignment.alignRows'
        assert.same(f({
            "ATGCTTGCTATTTAATGC",
            "ATGCATGC",
        }), {
            "ATGCTTGCTATTTAATGC",
            "ATGC----------ATGC",
        })
        --
        revert()
    end)

    it("align multiple rows (#addGapsForBetterIdentity)",
    function()
        local config = require 'npge.config'
        local revert = config:updateKeys({
            alignment = {
                MISMATCH_CHECK = 1,
                GAP_CHECK = 2,
            },
        })
        --
        local f = require 'npge.alignment.alignRows'
        assert.same(f({
            "GTAGTACCTGTTTTAGCCTTTGCTTCGAGAACCATGTGAA",
            "GTAGTACCTGCTCTGGCCTTTGCTTCGAGAACCATGTAAA",
            "GTAGTACCTGTCTGCCCTTCGCTCCGAGGACCATGTGAA",
            "GTAGTACCTGTTTTAGCCTTTGCTTCGAGAACCATGTGAA",
        }), {
            "GTAGTACCTGTTTTAGCCTTTGCTTCGAGAACCATGTGAA",
            "GTAGTACCTGCTCTGGCCTTTGCTTCGAGAACCATGTAAA",
            "GTAGTACCTG-TCTGCCCTTCGCTCCGAGGACCATGTGAA",
            "GTAGTACCTGTTTTAGCCTTTGCTTCGAGAACCATGTGAA",
        })
        --
        revert()
    end)

    it("align multiple rows (#addGapsForBetterIdentity_2)",
    function()
        local config = require 'npge.config'
        local revert = config:updateKeys({
            alignment = {
                MISMATCH_CHECK = 2,
                GAP_CHECK = 2,
            },
        })
        --
        local f = require 'npge.alignment.alignRows'
        assert.same(f({
            "ATGCGAT",
            "TACTAG",
        }), {
            "ATGCGAT",
            "-TACTAG",
        })
        --
        revert()
    end)

    it("align multiple rows (#addGapsForBetterIdentity_3)",
    function()
        local config = require 'npge.config'
        local revert = config:updateKeys({
            alignment = {
                MISMATCH_CHECK = 2,
                GAP_CHECK = 2,
            },
        })
        --
        local f = require 'npge.alignment.alignRows'
        assert.same(f({
            "ATGCGAT",
            "ATACTA",
        }), {
            "ATGCGAT",
            "ATACTA-",
        })
        --
        revert()
    end)
end)
