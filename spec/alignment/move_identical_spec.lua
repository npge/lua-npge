describe("alignment.move_identical", function()
    it("move identical columns from left (100%)", function()
        local move_identical =
            require 'npge.alignment.move_identical'
        local left, right = move_identical({
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

    it("move identical columns from left (0%)", function()
        local move_identical =
            require 'npge.alignment.move_identical'
        local left, right = move_identical({
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
        local move_identical =
            require 'npge.alignment.move_identical'
        local left, right = move_identical({
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
        local move_identical =
            require 'npge.alignment.move_identical'
        local left, right = move_identical({
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
        local move_identical =
            require 'npge.alignment.move_identical'
        local left, right = move_identical({
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
        local move_identical =
            require 'npge.alignment.move_identical'
        local left, right = move_identical({
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
