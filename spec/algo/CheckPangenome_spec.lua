-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

local AAA = ("A"):rep(1000)
local rand600 = [[
ACAAGCAAAGCAACGGGACTCCATCCCTAAGTCGTTTGTGAAGAAACGAGACTAATACGA
CATGGCAATTGTGAGGATATCAATTTGTAATATCGCGGCCATAGTGAGCACCTCAGAGCT
GATCCCCTGGAGATATCACCAGGTGGCGAGCGCAGGATAGCAACTATTAAAACGGTATCA
ACGCCATCTTTTGTACTTATGAGTGAGGTTGTATAATGCCCTATGATAGTTAGCTACCCT
ATGTGCTATACATCGACCATATTGTGCATGTGCACGCAGAATAGAGGCTGTGCGAATCTG
TGATGCCTCTTAGGGGAATGGGATTAGGACATTTGAATTAGCAATGGTGACAGCTCACTA
TAACTCTAACTCTCCCTGTGCATTATCGGTACTAGCCACCCTCTAGATATCCGATGTATC
TTGCTTGATTAAGCTCTTATCAATATCGGATCTAGGTACGGCGAGACCTAAAAATAGTGA
TACCAGTTGACACTTTTAACAACATTTCGCCCCGGCAAACACCATATGTGTTGTGCGCGA
GTCGAGTAGGCGTCGGCATAGGGACAATCGTTATCACTATCACACGCGGACAGTAGTACA
]]

describe("npge.algo.CheckPangenome", function()

    local revert

    before_each(function()
        local config = require 'npge.config'
        revert = config:updateKeys({
            general = {
                MIN_LENGTH = 100,
                MIN_IDENTITY = 0.9,
                MIN_END = 3,
            },
        })
    end)

    after_each(function()
        revert()
    end)

    it("refuses to check if genomes are unknown", function()
        local model = require 'npge.model'
        local seq = model.Sequence("seq", AAA)
        local bs = model.BlockSet({seq}, {})
        --
        local algo = require 'npge.algo'
        assert.has_error(function()
            local status, text = algo.CheckPangenome(bs)
        end)
    end)

    it("pangenome must be a partition", function()
        local model = require 'npge.model'
        local seq = model.Sequence("g&c&c", AAA)
        local bs = model.BlockSet({seq}, {})
        --
        local algo = require 'npge.algo'
        local status, text = algo.CheckPangenome(bs)
        assert.falsy(status)
        assert.equal(type(text), "string")
    end)

    it("pangenome must not include neighboring bad blocks",
    function()
        local model = require 'npge.model'
        local seq = model.Sequence("g&c&c", AAA)
        local u1 = model.Block({
            model.Fragment(seq, 0, 499, 1),
        })
        local u2 = model.Block({
            model.Fragment(seq, 500, 999, 1),
        })
        local m1 = model.Block({
            model.Fragment(seq, 500, 500, 1),
            model.Fragment(seq, 501, 501, 1),
        })
        local bs1 = model.BlockSet({seq}, {u1, u2})
        local bs2 = model.BlockSet({seq}, {u1, m1})
        --
        local algo = require 'npge.algo'
        local status, text = algo.CheckPangenome(bs1)
        assert.falsy(status)
        assert.equal(type(text), "string")
        local status, text = algo.CheckPangenome(bs2)
        assert.falsy(status)
        assert.equal(type(text), "string")
    end)

    it("block names must correspond their types, size, length",
    function()
        local model = require 'npge.model'
        local seq1 = model.Sequence("g1&c&c", rand600)
        local seq2 = model.Sequence("g2&c&c", rand600)
        local u1 = model.Block({
            model.Fragment(seq1, 0, 599, 1),
        })
        local u2 = model.Block({
            model.Fragment(seq2, 0, 599, 1),
        })
        local s2 = model.Block({
            model.Fragment(seq1, 0, 599, 1),
            model.Fragment(seq2, 0, 599, 1),
        })
        --
        local algo = require 'npge.algo'
        local function check(...)
            local bs = model.BlockSet(...)
            return algo.CheckPangenome(bs)
        end
        --
        assert.truthy(check({seq1}, {u1x600=u1}))
        assert.falsy(check({seq1}, {u1}))
        assert.truthy(check({seq1, seq2}, {s2x600=s2}))
        assert.falsy(check({seq1, seq2}, {s3x600=s2}))
        assert.falsy(check({seq1, seq2}, {s2x400=s2}))
    end)

    it("blocks must not be reverted", function()
        local model = require 'npge.model'
        local seq1 = model.Sequence("g1&c&c", rand600)
        local seq2 = model.Sequence("g2&c&c", rand600)
        local u1 = model.Block({
            model.Fragment(seq1, 0, 599, 1),
        })
        local u2 = model.Block({
            model.Fragment(seq2, 0, 599, 1),
        })
        local s2 = model.Block({
            model.Fragment(seq1, 0, 599, 1),
            model.Fragment(seq2, 0, 599, 1),
        })
        --
        local algo = require 'npge.algo'
        local function check(...)
            local bs = model.BlockSet(...)
            return algo.CheckPangenome(bs)
        end
        local reverse = require('npge.block').reverse
        --
        assert.truthy(check({seq1}, {u1x600=u1}))
        assert.falsy(check({seq1}, {u1x600=reverse(u1)}))
        assert.truthy(check({seq1, seq2}, {s2x600=s2}))
        assert.falsy(check({seq1, seq2}, {s2x600=reverse(s2)}))
    end)

    it("no blast hits can be added", function()
        local model = require 'npge.model'
        local seq1 = model.Sequence("g1&c&c", rand600)
        local seq2 = model.Sequence("g2&c&c", rand600)
        local u1 = model.Block({
            model.Fragment(seq1, 0, 599, 1),
        })
        local u2 = model.Block({
            model.Fragment(seq2, 0, 599, 1),
        })
        local s2 = model.Block({
            model.Fragment(seq1, 0, 599, 1),
            model.Fragment(seq2, 0, 599, 1),
        })
        --
        local algo = require 'npge.algo'
        local function check(...)
            local bs = model.BlockSet(...)
            return algo.CheckPangenome(bs)
        end
        --
        assert.truthy(check({seq1}, {u1x600=u1}))
        assert.truthy(check({seq2}, {u1x600n1=u2}))
        assert.truthy(check({seq1, seq2}, {s2x600=s2}))
        assert.falsy(check({seq1, seq2},
            {u1x600=u1, u1x600n1=u2}))
    end)

    it("no joined blocks can be formed", function()
        local model = require 'npge.model'
        local seq1 = model.Sequence("g1&c&c", rand600)
        local seq2 = model.Sequence("g2&c&c", rand600)
        local left = model.Block({
            model.Fragment(seq1, 0, 299, 1),
            model.Fragment(seq2, 0, 299, 1),
        })
        local right = model.Block({
            model.Fragment(seq1, 300, 599, 1),
            model.Fragment(seq2, 300, 599, 1),
        })
        local both = model.Block({
            model.Fragment(seq1, 0, 599, 1),
            model.Fragment(seq2, 0, 599, 1),
        })
        --
        local algo = require 'npge.algo'
        local function check(...)
            local bs = model.BlockSet(...)
            return algo.CheckPangenome(bs)
        end
        --
        assert.truthy(check({seq1, seq2}, {s2x600=both}))
        assert.falsy(check({seq1, seq2},
            {u1x600=left, u1x600n1=right}))
    end)
end)
