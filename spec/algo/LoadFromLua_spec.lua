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
        local blockset1 = LoadFromLua(lua)()
        assert.equal(blockset1, blockset)
    end)

    it("loads sequences + blockset", function()
        local model = require 'npge.model'
        local s = model.Sequence("test_name", "ATAT")
        if s.toRef then
            local f1 = model.Fragment(s, 0, 1, 1)
            local f2 = model.Fragment(s, 3, 2, -1)
            local block1 = model.Block({f2})
            local block2 = model.Block({f1})
            local blockset = model.BlockSet({s},
                {block1, block2})
            local readIt = require 'npge.util.readIt'
            local SequencesToLua =
                require 'npge.algo.SequencesToLua'
            local lua1 = readIt(SequencesToLua(blockset))
            local BlockSetToLua =
                require 'npge.algo.BlockSetToLua'
            local has_sequences = true
            local lua2 = readIt(BlockSetToLua(blockset,
                has_sequences))
            local LoadFromLua =
                require 'npge.algo.LoadFromLua'
            local enable_fromRef = true
            local name2seq = LoadFromLua(lua1,
                enable_fromRef)()
            local blockset1 = LoadFromLua(lua2)(name2seq)
            assert.equal(blockset1, blockset)
        end
    end)
end)
