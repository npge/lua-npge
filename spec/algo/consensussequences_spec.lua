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

    it("makes consensus sequences from blocks (2)", function()
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
        local cs, seq2block = ConsensusSequences(blockset)
        assert.same(cs:blocks(), {})
        local seqs = cs:sequences()
        assert.equal(#seqs, 2)
        local seq1, seq2
        if seq2block[seqs[1]] == b1 then
            seq1 = seqs[1]
            seq2 = seqs[2]
        elseif seq2block[seqs[1]] == b2 then
            seq2 = seqs[1]
            seq1 = seqs[2]
        else
            error('bad consensus sequences')
        end
        assert.equal(seq1:text(), "ATAT")
        assert.equal(seq2block[seq1], b1)
        assert.equal(seq2:text(), "TA")
        assert.equal(seq2block[seq2], b2)
    end)
end)
