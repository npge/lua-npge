local model = require 'npge.model'

describe("model.fragment", function()
    it("creates fragment", function()
        local s = model.Sequence("test_name", "ATGC")
        local f = model.Fragment(s, 0, 3, 1)
        assert.are.equal(f:seq(), s)
        assert.are.equal(f:start(), 0)
        assert.are.equal(f:stop(), 3)
        assert.are.equal(f:ori(), 1)
    end)
end)

