-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2016 Boris Nagaev
-- See the LICENSE file for terms of use.

describe("npge.alignment.left", function()
    it("align sequences from left to right",
    function()
        local left = require 'npge.alignment.left'
        local aligned, right = left({
            'ATTATTC',
            'ATTATTC',
        })
        assert.same(aligned, {
            'ATTATTC',
            'ATTATTC',
        })
        assert.same(right, {
            '',
            '',
        })
    end)

    it("align sequences from left to right (allow empty row)",
    function()
        local left = require 'npge.alignment.left'
        local aligned, right = left({
            'ATG',
            '',
        })
        assert.same(aligned, {
            '',
            '',
        })
        assert.same(right, {
            'ATG',
            '',
        })
    end)

    it("align sequences from left to right (empty rows list)",
    function()
        local left = require 'npge.alignment.left'
        local aligned, right = left({})
        assert.same(aligned, {})
        assert.same(right, {})
    end)

    it("align sequences from left to right (allow empty row 2)",
    function()
        local left = require 'npge.alignment.left'
        local aligned, right = left({
            '',
        })
        assert.same(aligned, {
            '',
        })
        assert.same(right, {
            '',
        })
    end)

    it("align sequences from left to right (#mismatches)",
    function()
        local config = require 'npge.config'
        local revert = config:updateKeys({
            alignment = {MISMATCH_CHECK = 1},
        })
        --
        local left = require 'npge.alignment.left'
        local aligned, right = left({
            'AGTATGC',
            'ATTCTTC',
        })
        assert.same(aligned, {
            'AGTATGC',
            'ATTCTTC',
        })
        assert.same(right, {
            '',
            '',
        })
        --
        revert()
    end)

    it("align sequences from left to right (#mismatches_2)",
    function()
        local config = require 'npge.config'
        local revert = config:updateKeys({
            alignment = {MISMATCH_CHECK = 2},
        })
        --
        local left = require 'npge.alignment.left'
        local aligned, right = left({
            'AGTATGC',
            'ATTAAGC',
        })
        assert.same(aligned, {
            'AGTATGC',
            'ATTAAGC',
        })
        assert.same(right, {
            '',
            '',
        })
        --
        revert()
    end)

    it("align sequences from left to right (#mismatches_fail)",
    function()
        local config = require 'npge.config'
        local revert = config:updateKeys({
            alignment = {
                MISMATCH_CHECK = 2,
                GAP_CHECK = 2,
            },
        })
        --
        local left = require 'npge.alignment.left'
        local aligned, right = left({
            'AGTATGA',
            'ATTTACC',
        })
        assert.same(aligned, {
            'A',
            'A',
        })
        assert.same(right, {
            'GTATGA',
            'TTTACC',
        })
        --
        revert()
    end)

    it("align sequences from left to right (#gaps over mm)",
    function()
        local config = require 'npge.config'
        local revert = config:updateKeys({
            alignment = {
                MISMATCH_CHECK = 2,
                GAP_CHECK = 1,
            },
        })
        --
        local left = require 'npge.alignment.left'
        local aligned, right = left({
            'AGTATGA',
            'ATTTACC',
        })
        assert.same(aligned, {
            'AGTAT',
            'A-T-T',
        })
        assert.same(right, {
            'GA',
            'TACC',
        })
        --
        revert()
    end)

    it("align sequences from left to right (#gaps)",
    function()
        local config = require 'npge.config'
        local revert = config:updateKeys({
            alignment = {
                GAP_CHECK = 1,
            },
        })
        --
        local left = require 'npge.alignment.left'
        local aligned, right = left({
            'ATTCTTC',
            'ATCTTC',
        })
        assert.same(aligned, {
            'ATTCTTC',
            'AT-CTTC',
        })
        assert.same(right, {
            '',
            '',
        })
        --
        revert()
    end)

    it("align sequences from left to right (#gaps 2)",
    function()
        local config = require 'npge.config'
        local revert = config:updateKeys({
            alignment = {
                MISMATCH_CHECK = 10,
                GAP_CHECK = 2,
            },
        })
        --
        local left = require 'npge.alignment.left'
        local aligned, right = left({
            'ATTCTTC',
            'TTTT',
        }, true)
        assert.same(aligned, {
            'ATTCTTC',
            '-TT-TT-',
        })
        assert.same(right, {
            '',
            '',
        })
        --
        revert()
    end)

    it("align sequences from left to right (#gaps 2)",
    function()
        local config = require 'npge.config'
        local revert = config:updateKeys({
            alignment = {
                MISMATCH_CHECK = 2,
                GAP_CHECK = 1,
            },
        })
        --
        local left = require 'npge.alignment.left'
        local aligned, right = left({
            'ATTCTTC',
            'ATTTTC',
        })
        assert.same(aligned, {
            'ATTCTTC',
            'ATT-TTC',
        })
        assert.same(right, {
            '',
            '',
        })
        --
        revert()
    end)

    it("align sequences from left (first col gap)",
    function()
        local config = require 'npge.config'
        local revert = config:updateKeys({
            alignment = {
                MISMATCH_CHECK = 10,
                GAP_CHECK = 1,
            },
        })
        --
        local left = require 'npge.alignment.left'
        local aligned, right = left({
            'ATTCTTC',
            'TTCTTC',
        })
        assert.same(aligned, {
            'ATTCTTC',
            '-TTCTTC',
        })
        assert.same(right, {
            '',
            '',
        })
        --
        revert()
    end)

    it("align sequences from left (first col mismatch)",
    function()
        local config = require 'npge.config'
        local revert = config:updateKeys({
            alignment = {
                MISMATCH_CHECK = 1,
            },
        })
        --
        local left = require 'npge.alignment.left'
        local aligned, right = left({
            'ATTCTTC',
            'GTTCTTC',
        })
        assert.same(aligned, {
            'ATTCTTC',
            'GTTCTTC',
        })
        assert.same(right, {
            '',
            '',
        })
        --
        revert()
    end)

    it("align sequences from left (right aligned, mism.)",
    function()
        local config = require 'npge.config'
        local revert = config:updateKeys({
            alignment = {
                MISMATCH_CHECK = 1,
            },
        })
        --
        local left = require 'npge.alignment.left'
        local aligned, right = left({
            'ATTCTTC',
            'ATTCTTG',
        }, true)
        assert.same(aligned, {
            'ATTCTTC',
            'ATTCTTG',
        })
        assert.same(right, {
            '',
            '',
        })
        --
        revert()
    end)

    it("align sequences (right aligned, mism., control)",
    function()
        local config = require 'npge.config'
        local revert = config:updateKeys({
            alignment = {
                MISMATCH_CHECK = 1,
            },
        })
        --
        local left = require 'npge.alignment.left'
        local aligned, right = left({
            'ATTCTTC',
            'ATTCTTG',
        })
        assert.same(aligned, {
            'ATTCTT',
            'ATTCTT',
        })
        assert.same(right, {
            'C',
            'G',
        })
        --
        revert()
    end)

    it("align sequences from left (#right_gap aligned)",
    function()
        local config = require 'npge.config'
        local revert = config:updateKeys({
            alignment = {
                GAP_CHECK = 1,
            },
        })
        --
        local left = require 'npge.alignment.left'
        local aligned, right = left({
            'ATTCTTC',
            'ATTCTT',
        }, true)
        assert.same(aligned, {
            'ATTCTTC',
            'ATTCTT-',
        })
        assert.same(right, {
            '',
            '',
        })
        --
        revert()
    end)

    it("align sequences (right aligned, gap., control)",
    function()
        local config = require 'npge.config'
        local revert = config:updateKeys({
            alignment = {
                GAP_CHECK = 1,
            },
        })
        --
        local left = require 'npge.alignment.left'
        local aligned, right = left({
            'ATTCTTC',
            'ATTCTT',
        })
        assert.same(aligned, {
            'ATTCTT',
            'ATTCTT',
        })
        assert.same(right, {
            'C',
            '',
        })
        --
        revert()
    end)

    it("align sequences from left to right (#right_tail)",
    function()
        local left = require 'npge.alignment.left'
        local aligned, right = left({
            'ATTCTTCAAA',
            'ATTCTTC',
        })
        assert.same(aligned, {
            'ATTCTTC',
            'ATTCTTC',
        })
        assert.same(right, {
            'AAA',
            '',
        })
    end)

    it("align sequences from left to right (3 rows)",
    function()
        local left = require 'npge.alignment.left'
        local aligned, right = left({
            'ATTATTC',
            'ATTATTC',
            'ATTATTC',
        })
        assert.same(aligned, {
            'ATTATTC',
            'ATTATTC',
            'ATTATTC',
        })
        assert.same(right, {
            '',
            '',
            '',
        })
    end)

    it("align sequences (#alternative gaps)",
    function()
        local config = require 'npge.config'
        local revert = config:updateKeys({
            alignment = {
                GAP_CHECK = 1,
                MISMATCH_CHECK = 1,
            },
        })
        --
        local left = require 'npge.alignment.left'
        local aligned, right = left({
            'ATTATATATC',
            'ATTTATATC',
        })
        assert.same(aligned, {
            'ATTATATATC',
            'ATT-TATATC',
        })
        assert.same(right, {
            '',
            '',
        })
        --
        revert()
    end)

    it("align sequences (#alternative gaps same lengths)",
    function()
        local config = require 'npge.config'
        local revert = config:updateKeys({
            alignment = {
                GAP_CHECK = 1,
                MISMATCH_CHECK = 1,
            },
        })
        --
        local left = require 'npge.alignment.left'
        local aligned, right = left({
            'ATTATATACC',
            'ATTTATATC',
        })
        --
        revert()
    end)

    it("align sequences (#alternative gaps long)",
    function()
        local config = require 'npge.config'
        local revert = config:updateKeys({
            alignment = {
                GAP_CHECK = 1,
                MISMATCH_CHECK = 1,
            },
        })
        --
        local TA = string.rep('TA', 1000)
        local left = require 'npge.alignment.left'
        local aligned, right = left({
            'ATTA' .. TA,
            'ATT' .. TA,
        })
        --
        revert()
    end)
end)
