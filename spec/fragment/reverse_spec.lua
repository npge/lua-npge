describe("fragment.reverse", function()
    it("gets reversed fragment", function()
        local model = require 'npge.model'
        local s = model.Sequence("s", "ATAT")
        local f = model.Fragment(s, 0, 3, 1)
        local reverse = require 'npge.fragment.reverse'
        assert.equal(reverse(f), model.Fragment(s, 3, 0, -1))
    end)
end)
