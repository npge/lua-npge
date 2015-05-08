-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

describe("npge.io.WriteSequencesToFasta", function()
    it("writes sequences to fasta file", function()
        local Sequence = require 'npge.model.Sequence'
        local s1 = Sequence('name', 'ATGC', 'description')
        local s2 = Sequence('seq1', 'ATGC')
        local s3 = Sequence('seq2', 'ATGCATGCATGC', 'bla bla')
        local BlockSet = require 'npge.model.BlockSet'
        local bs1 = BlockSet({s1, s2, s3}, {})
        local WriteSequencesToFasta =
            require 'npge.io.WriteSequencesToFasta'
        local it = WriteSequencesToFasta(bs1)
        local clone = require 'npge.util.clone'
        local fasta = clone.arrayFromIt(it)
        fasta = table.concat(fasta)
        local split = require 'npge.util.split'
        local lines = split(fasta, '\n')
        local itFromArray =
            require 'npge.util.itFromArray'
        local it = itFromArray(lines)
        local ReadSequencesFromFasta =
            require 'npge.io.ReadSequencesFromFasta'
        local bs2 = ReadSequencesFromFasta(it)
        assert.equal(bs1, bs2)
    end)
end)
