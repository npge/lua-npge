local arrays_equal = require 'npge.util.arrays_equal'

describe("util.arrays_equal", function()
    it("checks if arrays are equal", function()
        assert.is_true(arrays_equal({1, 2}, {1, 2}))
        assert.is_false(arrays_equal({1, 2}, {1, 2, 3}))
        assert.is_false(arrays_equal({1, 2}, {1, 0}))
    end)
end)

