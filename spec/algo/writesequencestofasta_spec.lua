describe("algo.WriteSequencesToFasta", function()
    it("writes sequences to fasta file", function()
        local Sequence = require 'npge.model.Sequence'
        local s1 = Sequence('name', 'ATGC', 'description')
        local s2 = Sequence('seq1', 'ATGC')
        local s3 = Sequence('seq2', 'ATGCATGCATGC', 'bla bla')
        local BlockSet = require 'npge.model.BlockSet'
        local bs1 = BlockSet({s1, s2, s3}, {})
        local WriteSequencesToFasta =
            require 'npge.algo.WriteSequencesToFasta'
        local it = WriteSequencesToFasta(bs1)
        local clone = require 'npge.util.clone'
        local fasta = clone.array_from_it(it)
        fasta = table.concat(fasta)
        local split = require 'npge.util.split'
        local lines = split(fasta, '\n')
        local it_from_array =
            require 'npge.util.it_from_array'
        local it = it_from_array(lines)
        local ReadSequencesFromFasta =
            require 'npge.algo.ReadSequencesFromFasta'
        local bs2 = ReadSequencesFromFasta(it)
        assert.equal(bs1, bs2)
    end)
end)
