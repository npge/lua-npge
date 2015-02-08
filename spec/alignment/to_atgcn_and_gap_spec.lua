describe("alignment.to_atgcn_and_gap", function()
    it("cleans all except ATGCN and gaps", function()
        local f = require 'npge.alignment.to_atgcn_and_gap'
        assert.are.equal(f("a T g"), "ATG")
        assert.are.equal(f("a T-g"), "AT-G")
        assert.are.equal(f("a T--\ng"), "AT--G")
        assert.are.equal(f(""), "")
    end)
end)
