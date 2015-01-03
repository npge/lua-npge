local clone = require 'npge.util.clone'

describe("util.clone", function()
    it("makes a copy of an array", function()
        local x = {1, 2}
        assert.same(clone.array(x), x)
        assert.not_equal(clone.array(x), x)
    end)

    it("makes a copy of a dict", function()
        local x = {a = 1, b = 'c', [1] = 0}
        assert.same(clone.dict(x), x)
        assert.not_equal(clone.dict(x), x)
    end)
end)


