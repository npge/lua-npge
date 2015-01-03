local cc = require 'npge.util.concat_arrays'

describe("util.concat_arrays", function()
    it("check if arrays are concatenated", function()
        assert.same(cc({1, 2}, {3, 4}), {1, 2, 3, 4})
    end)
end)

