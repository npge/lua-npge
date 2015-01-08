describe("block.at", function()
    it("gets letter in block at a position", function()
        local model = require 'npge.model'
        local s = model.Sequence("test_name", "AATAT")
        local f2 = model.Fragment(s, 4, 3, -1) -- AT
        local block = model.Block({
            {f2, 'A-T'},
        })
        local at = require 'npge.block.at'
        assert.are.equal(at(block, f2, 0), 'A')
        assert.are.equal(at(block, f2, 1), '-')
        assert.are.equal(at(block, f2, 2), 'T')
    end)
end)
