describe("alignment.complement_rows", function()
    it("calculates complement rows", function()
        local f = require 'npge.alignment.complement_rows'
        assert.same(f({"ATGC"}), {"GCAT"})
        assert.same(f({"ATGC", "AT-C"}), {"GCAT", "G-AT"})
    end)
end)
