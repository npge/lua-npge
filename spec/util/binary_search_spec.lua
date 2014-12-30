local binary_search = require 'npge.util.binary_search'

describe("util.binary_search", function()
    it("checks that binary search works", function()
        assert.equal(binary_search({1, 2, 3}, 1), 1)
        assert.equal(binary_search({1, 2, 3}, 2), 2)
        assert.equal(binary_search({1, 2, 3}, 3), 3)
    end)
end)


