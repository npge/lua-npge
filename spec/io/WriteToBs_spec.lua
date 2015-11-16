-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

describe("npge.io.WriteToBs", function()
    it("writes blockset to .bs file", function()
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
end)
