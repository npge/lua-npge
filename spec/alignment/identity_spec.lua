describe("alignment.identity", function()
    it("finds identity of rows (50%)", function()
        local identity = require 'npge.alignment.identity'
        local eq = require 'npge.block.identity'.eq
        assert.truthy(eq(identity({'AT', 'TT'}), 0.5))
    end)
end)
