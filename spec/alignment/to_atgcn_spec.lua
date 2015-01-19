describe("alignment.to_atgcn", function()
    it("converts to atgcn", function()
        local to_atgcn = require 'npge.alignment.to_atgcn'
        assert.are.equal(to_atgcn("a T g"), "ATG")
    end)
end)
