-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

describe("npge.algo.PangenomeMaker", function()
    it("converts blockset to pangenome", function()
        local config = require 'npge.config'
        local revert = config:updateKeys({
            general = {MIN_LENGTH = 60},
        })
        --
        local model = require 'npge.model'
        local s1 = model.Sequence('g1&chr1&l', [[
    TACCAGGGGAAGGGCCGAGGTGTCTGGTGATCA
TACGTATTGTGAATCTCTGGGGTGGCTGGTGATTGCGCAAACAAACTCACTCTGTAGGGA
    GGCAAAATAACCTCACATCTAGTCA
TACGTATTGTGAATCTCTGGGGTGGCTGGTGATTGCGCAAACAAACTCACTCTGTAGGGA
    AGTCGAGCCCGAGTGGATTAGTTACGAGTGC
        ]])
        local s2 = model.Sequence('g2&chr1&l', [[
    ATGGTGGCTCCGCAAAAAGCCGTTATAGCCGCAATGGCT
TACGTATTGTGAATCTCTGGGGTGGCTGGTGATTGCGCAAACAAACTCACTCTGTAGGGA
    TGACTAAGTTTCCCCTCAGCACTCTTCGCC
TCCCTACAGAGTGAGTTTGTTTGCGCAATCACCAGCCACCCCAGAGATTCACAATACGTA
    GATATTGGCTAATGCGAGTATCAGGCCGGGCA
        ]])
        local blockset = model.BlockSet({s1, s2}, {})
        --
        local algo = require 'npge.algo'
        local npg = algo.PangenomeMaker(blockset)
        assert.truthy(npg:isPartition())
        local good_blocks = algo.FilterGoodBlocks(npg):blocks()
        assert.equal(#good_blocks, 1)
        assert.equal(good_blocks[1]:size(), 4)
        assert.truthy(algo.CheckPangenome(npg))
        --
        revert()
    end)

    it("builds good pangenome from #mosses genomes", function()
        local good = dofile('spec/sample_pangenome2.lua')
        local npge = require 'npge'
        local seqs = npge.model.BlockSet(good:sequences(), {})
        assert.equal(#seqs:blocks(), 0)
        local pangenome = npge.algo.PangenomeMaker(seqs)
        assert.truthy(npge.algo.CheckPangenome(pangenome))
    end)
end)
