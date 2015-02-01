describe("algo.SequencesToLua", function()
    it("dumps sequences as references", function()
        local model = require 'npge.model'
        local s1 = model.Sequence("test_name1", "ATAT")
        local s2 = model.Sequence("test_name2", "TGCG", 'd')
        if s1.toRef then
            local blockset = model.BlockSet({s1, s2}, {})
            local SequencesToLua =
                require 'npge.algo.SequencesToLua'
            local readIt = require 'npge.util.readIt'
            local lua = readIt(SequencesToLua(blockset))
            local LoadFromLua = require 'npge.algo.LoadFromLua'
            local enable_fromRef = true
            local name2seq = LoadFromLua(lua, enable_fromRef)
            local seqs = {}
            for name, seq in pairs(name2seq) do
                table.insert(seqs, seq)
            end
            local blockset1 = model.BlockSet(seqs, {})
            assert.equal(blockset1, blockset)
        end
    end)
end)
