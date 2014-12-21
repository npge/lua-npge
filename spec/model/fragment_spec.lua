local Fragment = require 'npge.model.Fragment'
local Sequence = require 'npge.model.Sequence'

describe("model.fragment", function()
    it("creates fragment", function()
        local s = Sequence("test_name", "ATGC")
        local f = Fragment(s, 0, 3, 1)
        assert.are.equal(f:seq(), s)
        assert.are.equal(f:start(), 0)
        assert.are.equal(f:stop(), 3)
        assert.are.equal(f:ori(), 1)
    end)
end)

