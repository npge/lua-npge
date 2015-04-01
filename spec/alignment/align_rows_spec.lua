-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

describe("alignment.align_rows", function()
    it("align multiple rows (simple)", function()
        local f = require 'npge.alignment.align_rows'
        assert.same(f({"ATGC"}), {"ATGC"})
    end)

    it("align multiple rows (2 equal sequences)", function()
        local f = require 'npge.alignment.align_rows'
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
        local clone = require 'npge.util.clone'.dict
        local orig = clone(config.alignment)
        config.alignment.MISMATCH_CHECK = 1
        config.alignment.GAP_CHECK = 1
        config.alignment.ANCHOR = 4
        --
        local f = require 'npge.alignment.align_rows'
        assert.same(f({
            "ATGCTTTTTTTTTATGC",
            "ATGCATGC",
        }), {
            "ATGCTTTTTTTTTATGC",
            "ATGC---------ATGC",
        })
        --
        config.alignment = orig
    end)

    it("align multiple rows (long gap, 4 rows)", function()
        local config = require 'npge.config'
        local clone = require 'npge.util.clone'.dict
        local orig = clone(config.alignment)
        config.alignment.MISMATCH_CHECK = 1
        config.alignment.GAP_CHECK = 1
        config.alignment.ANCHOR = 4
        --
        local f = require 'npge.alignment.align_rows'
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
        config.alignment = orig
    end)

    it("align multiple rows (long gap, 4 rows, empty row)",
    function()
        local config = require 'npge.config'
        local clone = require 'npge.util.clone'.dict
        local orig = clone(config.alignment)
        config.alignment.MISMATCH_CHECK = 1
        config.alignment.GAP_CHECK = 1
        config.alignment.ANCHOR = 4
        --
        local f = require 'npge.alignment.align_rows'
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
        config.alignment = orig
    end)

    it("align multiple rows (long gap, #4_rows, double)",
    function()
        local config = require 'npge.config'
        local clone = require 'npge.util.clone'.dict
        local orig = clone(config.alignment)
        config.alignment.MISMATCH_CHECK = 1
        config.alignment.GAP_CHECK = 2
        config.alignment.ANCHOR = 4
        --
        local f = require 'npge.alignment.align_rows'
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
        config.alignment = orig
    end)

    it("align multiple rows (#only_left)", function()
        local config = require 'npge.config'
        local clone = require 'npge.util.clone'.dict
        local orig = clone(config.alignment)
        config.alignment.MISMATCH_CHECK = 1
        config.alignment.GAP_CHECK = 1
        --
        local f = require 'npge.alignment.align_rows'
        assert.same(f({
            "ATGCTTGCTATTTAATGC",
            "ATGCATGC",
        }, true), {
            "ATGCTTGCTATTTAATGC",
            "ATGCATGC----------",
        })
        --
        config.alignment = orig
    end)

    it("align multiple rows (#only_left control)", function()
        local config = require 'npge.config'
        local clone = require 'npge.util.clone'.dict
        local orig = clone(config.alignment)
        config.alignment.MISMATCH_CHECK = 1
        config.alignment.GAP_CHECK = 1
        --
        local f = require 'npge.alignment.align_rows'
        assert.same(f({
            "ATGCTTGCTATTTAATGC",
            "ATGCATGC",
        }), {
            "ATGCTTGCTATTTAATGC",
            "ATGC----------ATGC",
        })
        --
        config.alignment = orig
    end)

    it("align multiple rows (#addGapsForBetterIdentity)",
    function()
        local config = require 'npge.config'
        local clone = require 'npge.util.clone'.dict
        local orig = clone(config.alignment)
        config.alignment.MISMATCH_CHECK = 1
        config.alignment.GAP_CHECK = 2
        --
        local f = require 'npge.alignment.align_rows'
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
        config.alignment = orig
    end)

    it("align multiple rows (#addGapsForBetterIdentity_2)",
    function()
        local config = require 'npge.config'
        local clone = require 'npge.util.clone'.dict
        local orig = clone(config.alignment)
        config.alignment.MISMATCH_CHECK = 2
        config.alignment.GAP_CHECK = 2
        --
        local f = require 'npge.alignment.align_rows'
        assert.same(f({
            "ATGCGAT",
            "TACTAG",
        }), {
            "ATGCGAT",
            "-TACTAG",
        })
        --
        config.alignment = orig
    end)

    it("align multiple rows (#addGapsForBetterIdentity_3)",
    function()
        local config = require 'npge.config'
        local clone = require 'npge.util.clone'.dict
        local orig = clone(config.alignment)
        config.alignment.MISMATCH_CHECK = 2
        config.alignment.GAP_CHECK = 2
        --
        local f = require 'npge.alignment.align_rows'
        assert.same(f({
            "ATGCGAT",
            "ATACTA",
        }), {
            "ATGCGAT",
            "ATACTA-",
        })
        --
        config.alignment = orig
    end)
end)
