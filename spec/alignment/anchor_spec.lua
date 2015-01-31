describe("alignment.anchor", function()
    it("finds anchor of identical words in sequences",
    function()
        local config = require 'npge.config'
        local orig_ANCHOR = config.alignment.ANCHOR
        config.alignment.ANCHOR = 7
        local anchor = require 'npge.alignment.anchor'
        local left, middle, right = anchor({
            'ATTATTC',
            'ATTATTC',
        })
        assert.same(left, {
            '',
            '',
        })
        assert.same(middle, {
            'ATTATTC',
            'ATTATTC',
        })
        assert.same(right, {
            '',
            '',
        })
        config.alignment.ANCHOR = orig_ANCHOR
    end)

    it("returns nil if list of rows is empty",
    function()
        local anchor = require 'npge.alignment.anchor'
        local left, middle, right = anchor({})
        assert.same(left, nil)
    end)

    it("finds anchor (shift in #one fragment)",
    function()
        local config = require 'npge.config'
        local orig_ANCHOR = config.alignment.ANCHOR
        config.alignment.ANCHOR = 7
        local anchor = require 'npge.alignment.anchor'
        local left, middle, right = anchor({
            'ATTATTC',
            'GGGGGGGATTATTC',
        })
        assert.same(left, {
            '',
            'GGGGGGG',
        })
        assert.same(middle, {
            'ATTATTC',
            'ATTATTC',
        })
        assert.same(right, {
            '',
            '',
        })
        config.alignment.ANCHOR = orig_ANCHOR
    end)

    it("finds anchor (shift in all fragments)",
    function()
        local config = require 'npge.config'
        local orig_ANCHOR = config.alignment.ANCHOR
        config.alignment.ANCHOR = 7
        local anchor = require 'npge.alignment.anchor'
        local left, middle, right = anchor({
            'TTTTTTTATTATTC',
            'GGGGGGGATTATTC',
        })
        assert.same(left, {
            'TTTTTTT',
            'GGGGGGG',
        })
        assert.same(middle, {
            'ATTATTC',
            'ATTATTC',
        })
        assert.same(right, {
            '',
            '',
        })
        config.alignment.ANCHOR = orig_ANCHOR
    end)

    it("finds anchor (prefer same shift)",
    function()
        local config = require 'npge.config'
        local orig_ANCHOR = config.alignment.ANCHOR
        config.alignment.ANCHOR = 7
        local anchor = require 'npge.alignment.anchor'
        local left, middle, right = anchor({
            'ATTATTCATTATTC',
            'GGGGGGGATTATTC',
        })
        assert.same(left, {
            'ATTATTC',
            'GGGGGGG',
        })
        assert.same(middle, {
            'ATTATTC',
            'ATTATTC',
        })
        assert.same(right, {
            '',
            '',
        })
        config.alignment.ANCHOR = orig_ANCHOR
    end)

    it("finds anchor of identical words in sequences (none)",
    function()
        local config = require 'npge.config'
        local orig_ANCHOR = config.alignment.ANCHOR
        config.alignment.ANCHOR = 7
        local anchor = require 'npge.alignment.anchor'
        local left, middle, right = anchor({
            'ATTATTCATTATTC',
            'GGGGGGGATTACCT',
        })
        assert.falsy(left)
        assert.falsy(middle)
        assert.falsy(right)
        config.alignment.ANCHOR = orig_ANCHOR
    end)

    it("finds anchor (3 fragments)",
    function()
        local config = require 'npge.config'
        local orig_ANCHOR = config.alignment.ANCHOR
        config.alignment.ANCHOR = 7
        local anchor = require 'npge.alignment.anchor'
        local left, middle, right = anchor({
            'TTTTTTTATTATTC',
            'GGGGGGGATTATTC',
            'AAAAAAAATTATTC',
        })
        assert.same(left, {
            'TTTTTTT',
            'GGGGGGG',
            'AAAAAAA',
        })
        assert.same(middle, {
            'ATTATTC',
            'ATTATTC',
            'ATTATTC',
        })
        assert.same(right, {
            '',
            '',
            '',
        })
        config.alignment.ANCHOR = orig_ANCHOR
    end)

    it("finds anchor (right)",
    function()
        local config = require 'npge.config'
        local orig_ANCHOR = config.alignment.ANCHOR
        config.alignment.ANCHOR = 7
        local anchor = require 'npge.alignment.anchor'
        local left, middle, right = anchor({
            'ATTATTCCCC',
            'ATTATTC',
        })
        assert.same(left, {
            '',
            '',
        })
        assert.same(middle, {
            'ATTATTC',
            'ATTATTC',
        })
        assert.same(right, {
            'CCC',
            '',
        })
        config.alignment.ANCHOR = orig_ANCHOR
    end)
end)
