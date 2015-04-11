-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

describe("npge.sequence.to_fasta", function()
    it("converts sequence to fasta", function()
        local model = require 'npge.model'
        local s = model.Sequence("g&c&c",
            string.rep("ATAT", 100))
        local to_fasta = require 'npge.sequence.to_fasta'
        local fasta = to_fasta(s)
        local split = require 'npge.util.split'
        local lines = split(fasta, '\n')
        local itFromArray = require 'npge.util.itFromArray'
        local it = itFromArray(lines)
        local ReadSequencesFromFasta =
            require 'npge.algo.ReadSequencesFromFasta'
        local bs = ReadSequencesFromFasta(it)
        assert.equal(bs, model.BlockSet({s}, {}))
    end)
end)
