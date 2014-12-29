local arrays_less = require 'npge.util.arrays_less'

describe("util.arrays_less", function()
    it("checks if one array is less than another", function()
        assert.is_false(arrays_less({1, 2}, {1, 2}))
        assert.is_true(arrays_less({1, 1}, {1, 2}))
        assert.is_true(arrays_less({0, 2}, {1, 2}))
        assert.is_false(arrays_less({4, 2}, {1, 2}))
        assert.has_error(function()
            arrays_less({1, 2}, {1, 2, 3})
        end)
    end)
end)

