describe("algo.ConsensusSequences", function()
    it("makes consensus sequences from blocks", function()
        local model = require 'npge.model'
        local s = model.Sequence("s", "ATAT")
        local f = model.Fragment(s, 0, 3, 1)
        local b = model.Block({f})
        local blockset = model.BlockSet({s}, {b})
        local ConsensusSequences =
            require 'npge.algo.ConsensusSequences'
        local cs, seq2block = ConsensusSequences(blockset)
        assert.same(cs:blocks(), {})
        local sequences = cs:sequences()
        assert.equal(#sequences, 1)
        local sequence = sequences[1]
        assert.equal(sequence:text(), "ATAT")
        assert.equal(seq2block[sequence], b)
    end)

    it("throws if original blocks overlap",
    function()
        local model = require 'npge.model'
        local s = model.Sequence("g&c&c", "ATAT")
        local b1 = model.Block({model.Fragment(s, 0, 3, 1)})
        local b2 = model.Block({
            model.Fragment(s, 1, 2, 1),
            model.Fragment(s, 0, 3, -1),
        })
        local blockset = model.BlockSet({s}, {b1, b2})
        local ConsensusSequences =
            require 'npge.algo.ConsensusSequences'
        assert.has_error(function()
            local cs, seq2block = ConsensusSequences(blockset)
        end)
    end)
end)
