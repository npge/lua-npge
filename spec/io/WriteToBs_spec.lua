-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

describe("npge.io.WriteToBs", function()
    it("writes blockset (partition) to .bs file", function()
        local npge = require 'npge'
        local model = npge.model
        local seq = model.Sequence('BRUAB&chr1&c', 'ATTCCC')
        local parted = model.Fragment(seq, 4, 1, 1)
        local nonparted = model.Fragment(seq, 2, 3, 1)
        local block = model.Block({parted, nonparted})
        local bs = model.BlockSet({seq}, {block})
        -- read with reference
        local it = npge.io.WriteToBs(bs)
        local bs_with_sequences = model.BlockSet({seq}, {})
        local bs2 = npge.io.ReadFromBs(it, bs_with_sequences)
        assert.equal(bs2, bs)
        -- read without reference
        local it = npge.io.WriteToBs(bs)
        local bs2 = npge.io.ReadFromBs(it)
        assert.equal(bs2, bs)
    end)

    it("writes blockset (#non-partition) to .bs file", function()
        local npge = require 'npge'
        local model = npge.model
        local seq1 = model.Sequence('BRUAB&chr1&c', 'ATTCCC')
        local seq2 = model.Sequence('BRUAO&chr2&c', 'ATTCCC')
        local parted1 = model.Fragment(seq1, 4, 1, 1)
        local parted2 = model.Fragment(seq2, 1, 3, -1)
        local block = model.Block({parted1, parted2})
        local bs = model.BlockSet({seq1, seq2}, {block})
        -- read with reference
        local it = npge.io.WriteToBs(bs)
        local bs_with_sequences = model.BlockSet({seq1, seq2}, {})
        local bs2 = npge.io.ReadFromBs(it, bs_with_sequences)
        assert.equal(bs2, bs)
        -- read without reference
        local it = npge.io.WriteToBs(bs)
        local bs2 = npge.io.ReadFromBs(it)
        assert.equal(bs2, bs)
    end)
end)
