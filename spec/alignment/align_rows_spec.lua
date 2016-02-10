-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2016 Boris Nagaev
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

    it("align multiple rows (#only_left #mosses)", function()
        local config = require 'npge.config'
        local revert = config:updateKeys({
            alignment = {
                MISMATCH_CHECK = 1,
                GAP_CHECK = 2,
                ANCHOR = 7,
            },
        })
        --
        local f = require 'npge.alignment.alignRows'
        assert.same(f({
            "TCCGTACAAAACGATTCATAAATTCGCTATGTAAATG",
            "TCCGTACAAAACGATTCATAAATTCGCTATGTAAATG",
            "TCCGTACAAAACGATTCATGAATTAGCTATGT",
        }, true), {
            "TCCGTACAAAACGATTCATAAATTCGCTATGTAAATG",
            "TCCGTACAAAACGATTCATAAATTCGCTATGTAAATG",
            "TCCGTACAAAACGATTCATGAATTAGCTATGT-----",
        })
        --
        revert()
    end)

    it("align multiple rows (#only_left #mosses2)", function()
        local config = require 'npge.config'
        local revert = config:updateKeys({
            alignment = {
                MISMATCH_CHECK = 1,
                GAP_CHECK = 2,
                ANCHOR = 7,
            },
        })
        --
        local f = require 'npge.alignment.alignRows'
        assert.same(f({
            "CTTAGACACTCTTGGACCTTGCATCACCGAAGGCTCCCTGAGCT" ..
            "GAAACCGCTTCGAGCTGTTTCCGTACAAAACGATTCATAAATTC" ..
            "GCTATGTAAATG",
            "CTTAGACACTCTTGGACCTTGCATCACCGAAGGCTCCCTGAGCT" ..
            "GAAACCGCTTCGAGCTGTTTCCGTACAAAACGATTCATAAATTC" ..
            "GCTATGTAAATG",
            "ATTTAGAGAGAGACTCTTAAGCCTTTCATCACCGGAGGCTCCTA" ..
            "GAGCTGAAACCGCTTCAAGTTGTTTCCGTACAAAACGATTCATG" ..
            "AATTAGCTATGT",
        }, true), {
            "CTT-AGACA----CTCTTGGACCTTGCATCACCGAAGGCTCCCT" ..
            "GAGCTGAAACCGCTTCGAGCTGTTTCCGTACAAAACGATTCATA" ..
            "AATTCGCTATGTAAATG",
            "CTT-AGACA----CTCTTGGACCTTGCATCACCGAAGGCTCCCT" ..
            "GAGCTGAAACCGCTTCGAGCTGTTTCCGTACAAAACGATTCATA" ..
            "AATTCGCTATGTAAATG",
            "ATTTAGAGAGAGACTCTTAAGCCTTTCATCACCGGAGGCTCCTA" ..
            "GAGCTGAAACCGCTTCAAGTTGTTTCCGTACAAAACGATTCATG" ..
            "AATTAGCTATGT-----",
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

    it("finds shorter anchor", function()
        local f = require 'npge.alignment.alignRows'
        local rows1 = f({
            "GAATCTAGTCCATCCAATTCTGGGC",
            "GAATCTAGTCCAATTCCGGGC",
            "GAGAATCTAGTCCATTTAATCCCGGGC",
            "AAATTTAGTCTAATTCTAGAC",
            "GAATCTAGTCTGATTCCAGGC",
            "GAATCTAGTCCATCCAATTCCGGGG",
            "GAATCTAGTCCATCCAATTCTGGAC",
        })
        local identity = require 'npge.alignment.identity'
        assert.truthy(identity(rows1) > 0.4)
        -- can be even better
--[[
>1
GA--ATCTAGTCCATCCAATTCTGGGC
>2
GA--ATCTAGTCCA----ATTCCGGGC
>3
GAGAATCTAGTCCATTTAATCCCGGGC
>4
AA--ATTTAGTC----TAATTCTAGAC
>5
GA--ATCTAGTC----TGATTCCAGGC
>6
GA--ATCTAGTCCATCCAATTCCGGGG
>7
GA--ATCTAGTCCATCCAATTCTGGAC
]]
    end)
end)
