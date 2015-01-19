describe("alignment.left", function()
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

    it("align sequences from left to right (#mismatches)",
    function()
        local config = require 'npge.config'
        local clone = require 'npge.util.clone'.dict
        local orig = clone(config.alignment)
        config.alignment.MISMATCH_CHECK = 1
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
        config.alignment = orig
    end)

    it("align sequences from left to right (#mismatches_2)",
    function()
        local config = require 'npge.config'
        local clone = require 'npge.util.clone'.dict
        local orig = clone(config.alignment)
        config.alignment.MISMATCH_CHECK = 2
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
        config.alignment = orig
    end)

    it("align sequences from left to right (#mismatches_fail)",
    function()
        local config = require 'npge.config'
        local clone = require 'npge.util.clone'.dict
        local orig = clone(config.alignment)
        config.alignment.MISMATCH_CHECK = 2
        config.alignment.GAP_CHECK = 2
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
        config.alignment = orig
    end)

    it("align sequences from left to right (#gaps over mm)",
    function()
        local config = require 'npge.config'
        local clone = require 'npge.util.clone'.dict
        local orig = clone(config.alignment)
        config.alignment.MISMATCH_CHECK = 2
        config.alignment.GAP_CHECK = 1
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
        config.alignment = orig
    end)

    it("align sequences from left to right (#gaps)",
    function()
        local config = require 'npge.config'
        local clone = require 'npge.util.clone'.dict
        local orig = clone(config.alignment)
        config.alignment.GAP_CHECK = 1
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
        config.alignment = orig
    end)

    it("align sequences from left to right (#gaps 2)",
    function()
        local config = require 'npge.config'
        local clone = require 'npge.util.clone'.dict
        local orig = clone(config.alignment)
        config.alignment.MISMATCH_CHECK = 10
        config.alignment.GAP_CHECK = 2
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
        config.alignment = orig
    end)

    it("align sequences from left to right (#gaps 2)",
    function()
        local config = require 'npge.config'
        local clone = require 'npge.util.clone'.dict
        local orig = clone(config.alignment)
        config.alignment.GAP_CHECK = 1
        config.alignment.MISMATCH_CHECK = 2
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
        config.alignment = orig
    end)

    it("align sequences from left (first col gap)",
    function()
        local config = require 'npge.config'
        local clone = require 'npge.util.clone'.dict
        local orig = clone(config.alignment)
        config.alignment.GAP_CHECK = 1
        config.alignment.MISMATCH_CHECK = 10
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
        config.alignment = orig
    end)

    it("align sequences from left (first col mismatch)",
    function()
        local config = require 'npge.config'
        local clone = require 'npge.util.clone'.dict
        local orig = clone(config.alignment)
        config.alignment.MISMATCH_CHECK = 1
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
        config.alignment = orig
    end)

    it("align sequences from left (right aligned, mism.)",
    function()
        local config = require 'npge.config'
        local clone = require 'npge.util.clone'.dict
        local orig = clone(config.alignment)
        config.alignment.MISMATCH_CHECK = 1
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
        config.alignment = orig
    end)

    it("align sequences (right aligned, mism., control)",
    function()
        local config = require 'npge.config'
        local clone = require 'npge.util.clone'.dict
        local orig = clone(config.alignment)
        config.alignment.MISMATCH_CHECK = 1
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
        config.alignment = orig
    end)

    it("align sequences from left (#right_gap aligned)",
    function()
        local config = require 'npge.config'
        local clone = require 'npge.util.clone'.dict
        local orig = clone(config.alignment)
        config.alignment.GAP_CHECK = 1
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
        config.alignment = orig
    end)

    it("align sequences (right aligned, gap., control)",
    function()
        local config = require 'npge.config'
        local clone = require 'npge.util.clone'.dict
        local orig = clone(config.alignment)
        config.alignment.GAP_CHECK = 1
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
        config.alignment = orig
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
        local clone = require 'npge.util.clone'.dict
        local orig = clone(config.alignment)
        config.alignment.GAP_CHECK = 1
        config.alignment.MISMATCH_CHECK = 1
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
        config.alignment = orig
    end)
end)
