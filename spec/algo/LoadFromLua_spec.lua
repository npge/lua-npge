describe("algo.LoadFromLua", function()
    it("loads Lua files in #sandbox", function()
        local model = require 'npge.model'
        local s = model.Sequence("test_name", "ATAT")
        local f1 = model.Fragment(s, 0, 1, 1)
        local f2 = model.Fragment(s, 3, 2, -1)
        local block1 = model.Block({f2})
        local block2 = model.Block({f1})
        local blockset = model.BlockSet({s}, {block1, block2})
        local BlockSetToLua = require 'npge.algo.BlockSetToLua'
        local readIt = require 'npge.util.readIt'
        local lua = readIt(BlockSetToLua(blockset))
        local LoadFromLua = require 'npge.algo.LoadFromLua'
        local blockset1 = LoadFromLua(lua)
        assert.equal(blockset1, blockset)
    end)
end)
