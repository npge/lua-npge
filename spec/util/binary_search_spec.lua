local binary_search = require 'npge.util.binary_search'

describe("util.binary_search", function()
    it("checks that binary search works (lower)", function()
        local lower = binary_search.lower
        assert.equal(lower({1, 2, 3}, 0), 1)
        assert.equal(lower({1, 2, 3}, 1), 1)
        assert.equal(lower({1, 2, 3}, 2), 2)
        assert.equal(lower({1, 2, 3}, 3), 3)
        assert.equal(lower({1, 2, 3}, 4), 4)
        assert.equal(lower({1, 2, 3}, 5), 4)
        --
        assert.equal(lower({1, 2, 2}, 2), 2)
        assert.equal(lower({1, 2, 2}, 1.5), 2)
        assert.equal(lower({1, 2, 2}, 3), 4)
    end)

    it("checks that binary search works (upper)", function()
        local upper = binary_search.upper
        assert.equal(upper({1, 2, 3}, 0), 1)
        assert.equal(upper({1, 2, 3}, 1), 2)
        assert.equal(upper({1, 2, 3}, 2), 3)
        assert.equal(upper({1, 2, 3}, 3), 4)
        assert.equal(upper({1, 2, 3}, 4), 4)
        assert.equal(upper({1, 2, 3}, 5), 4)
        --
        assert.equal(upper({1, 2, 2}, 2), 4)
        assert.equal(upper({1, 2, 2}, 1.5), 2)
        assert.equal(upper({1, 2, 2}, 3), 4)
    end)
end)


