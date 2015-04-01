-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

describe("algo.ReadSequencesFromFasta", function()
    it("reads sequences from fasta file", function()
        local ReadSequencesFromFasta =
            require 'npge.algo.ReadSequencesFromFasta'
        local it_from_array =
            require 'npge.util.it_from_array'
        local split = require 'npge.util.split'
        local fasta =
[[
>name description
AT
GC
>seq1
ATGC
>seq2 bla bla
ATGC
ATGC
ATGC
]]
        local lines = split(fasta, '\n')
        local it = it_from_array(lines)
        local bs1 = ReadSequencesFromFasta(it)
        --
        local Sequence = require 'npge.model.Sequence'
        local s1 = Sequence('name', 'ATGC', 'description')
        local s2 = Sequence('seq1', 'ATGC')
        local s3 = Sequence('seq2', 'ATGCATGCATGC', 'bla bla')
        local BlockSet = require 'npge.model.BlockSet'
        local bs2 = BlockSet({s1, s2, s3}, {})
        assert.equal(bs1, bs2)
    end)
end)
