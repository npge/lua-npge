local cc = require 'npge.util.arrays_concat'

describe("util.arrays_concat", function()
    it("check if arrays are concatenated", function()
        assert.same(cc({1, 2}, {3, 4}), {1, 2, 3, 4})
    end)
end)

