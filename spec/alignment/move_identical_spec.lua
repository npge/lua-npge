-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

describe("npge.alignment.moveIdentical", function()
    it("move identical columns from left (100%)", function()
        local moveIdentical =
            require 'npge.alignment.moveIdentical'
        local left, right = moveIdentical({
            'ATGC',
            'ATGC',
        })
        assert.same(left, {
            'ATGC',
            'ATGC',
        })
        assert.same(right, {
            '',
            '',
        })
    end)

    it("move identical columns from left (no rows)", function()
        local moveIdentical =
            require 'npge.alignment.moveIdentical'
        local left, right = moveIdentical({})
        assert.same(left, {})
        assert.same(right, {})
    end)

    it("move identical columns from left (0%)", function()
        local moveIdentical =
            require 'npge.alignment.moveIdentical'
        local left, right = moveIdentical({
            'TACG',
            'ATGC',
        })
        assert.same(left, {
            '',
            '',
        })
        assert.same(right, {
            'TACG',
            'ATGC',
        })
    end)

    it("move identical columns from left (mismatch)",
    function()
        local moveIdentical =
            require 'npge.alignment.moveIdentical'
        local left, right = moveIdentical({
            'ATGC',
            'ATGN',
        })
        assert.same(left, {
            'ATG',
            'ATG',
        })
        assert.same(right, {
            'C',
            'N',
        })
    end)

    it("move identical columns from left (empty)",
    function()
        local moveIdentical =
            require 'npge.alignment.moveIdentical'
        local left, right = moveIdentical({
            'ATGC',
            '',
        })
        assert.same(left, {
            '',
            '',
        })
        assert.same(right, {
            'ATGC',
            '',
        })
    end)

    it("move identical columns from left (empty 2)",
    function()
        local moveIdentical =
            require 'npge.alignment.moveIdentical'
        local left, right = moveIdentical({
            '',
        })
        assert.same(left, {
            '',
        })
        assert.same(right, {
            '',
        })
    end)

    it("move identical columns from left (gap)",
    function()
        local moveIdentical =
            require 'npge.alignment.moveIdentical'
        local left, right = moveIdentical({
            'ATGC',
            'ATG',
        })
        assert.same(left, {
            'ATG',
            'ATG',
        })
        assert.same(right, {
            'C',
            '',
        })
    end)
end)
