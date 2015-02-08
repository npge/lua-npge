describe("alignment.complement", function()
    it("calculates complement sequence", function()
        local complement = require 'npge.alignment.complement'
        assert.are.equal(complement("ATGC"), "GCAT")
        assert.are.equal(complement(""), "")
    end)
end)
