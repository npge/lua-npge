-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

local AAA = ("A"):rep(1000)
local AAA100 = ("A"):rep(100)
local CCC100 = ("C"):rep(100)
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
local rand600_bad_ends_10 = [[
nnnnnnnnnnCAACGGGACTCCATCCCTAAGTCGTTTGTGAAGAAACGAGACTAATACGA
CATGGCAATTGTGAGGATATCAATTTGTAATATCGCGGCCATAGTGAGCACCTCAGAGCT
GATCCCCTGGAGATATCACCAGGTGGCGAGCGCAGGATAGCAACTATTAAAACGGTATCA
ACGCCATCTTTTGTACTTATGAGTGAGGTTGTATAATGCCCTATGATAGTTAGCTACCCT
ATGTGCTATACATCGACCATATTGTGCATGTGCACGCAGAATAGAGGCTGTGCGAATCTG
TGATGCCTCTTAGGGGAATGGGATTAGGACATTTGAATTAGCAATGGTGACAGCTCACTA
TAACTCTAACTCTCCCTGTGCATTATCGGTACTAGCCACCCTCTAGATATCCGATGTATC
TTGCTTGATTAAGCTCTTATCAATATCGGATCTAGGTACGGCGAGACCTAAAAATAGTGA
TACCAGTTGACACTTTTAACAACATTTCGCCCCGGCAAACACCATATGTGTTGTGCGCGA
GTCGAGTAGGCGTCGGCATAGGGACAATCGTTATCACTATCACACGCGGAnnnnnnnnnn
]]
local rand100n1 = [[
GGGGACCTCAGTAAACACACATCGGGAAAGACTGTTTAGTAAGAACCAGCAGTCACTTAT
TCCCTCCGACTGAGCACCTTTACCGTTAGGTCGACCCGTC
]]
local rand100n2 = [[
CATAGTTGCAGATTTCCAGAGGTGGCTATTTATGAAATGCGACCTAGTATTCCGTTTGTG
AGTCCATAACAGTATGATCTTGTCCTCCTTATATACTGCG
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

    it("pangenome must no include blocks of type '#bad'",
    function()
        local model = require 'npge.model'
        local seq1b = model.Sequence("g1&c&c", rand100n1)
        local seq1a = model.Sequence("g1&c&c",
            seq1b:text():sub(1, 99))
        local seq2b = model.Sequence("g2&c&c", rand100n2)
        local seq2a = model.Sequence("g2&c&c",
            seq2b:text():sub(1, 99))
        local u1a = model.Block({
            model.Fragment(seq1a, 0, 98, 1),
        })
        local u2a = model.Block({
            model.Fragment(seq2a, 0, 98, 1),
        })
        local u2b = model.Block({
            model.Fragment(seq2b, 0, 99, 1),
        })
        local s2a = model.Block({
            model.Fragment(seq1a, 0, 98, 1),
            model.Fragment(seq2a, 0, 98, 1),
        })
        local s2b = model.Block({
            model.Fragment(seq1a, 0, 98, 1),
            model.Fragment(seq2b, 0, 99, 1),
        })
        --
        local algo = require 'npge.algo'
        local function check(...)
            local bs = model.BlockSet(...)
            bs = algo.GiveNames(algo.Cover(bs))
            return algo.CheckPangenome(bs)
        end
        --
        assert.truthy(check({seq1a, seq2a}, {u1a, u2a}))
        assert.truthy(check({seq1a, seq2b}, {u1a, u2b}))
        assert.truthy(check({seq1a, seq2a}, {s2a}))
        assert.falsy(check({seq1a, seq2b}, {s2b}))
        local blockType = require 'npge.block.blockType'
        assert.equal(blockType(s2a, 2), 'minor')
        assert.equal(blockType(s2b, 2), 'bad')
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

    it("no blast hits can be added (control)", function()
        local model = require 'npge.model'
        local seq1 = model.Sequence("g1&c&l", [[
GTAATAATGTGCGCTTTTGTATTTAGCGTTCCGCACCAATTGACTGTGCCAAAAAAAAAA
CTTGCTATTGATAGCGGTGCGTGCGAGGAGCCCATGGGCCACTATAGATACCGTCATTCT
        ]])
        -- replace 10 bases with complement
        local seq2 = model.Sequence("g2&c&l", [[
GTAATAATGTGCGCTTTTGTATTTAGCGTTCCGCACCAATTGACTGTGCCAAAAAAAAAA
GAACGATAACATAGCGGTGCGTGCGAGGAGCCCATGGGCCACTATAGATACCGTCATTCT
        ]])
        local seq3 = model.Sequence("g3&c&l", [[
GTAATAATGTGCGCTTTTGTATTTAGCGTTCCGCACCAATTGACTGTGCCTTTTTTTTTT
GAACGATAACATAGCGGTGCGTGCGAGGAGCCCATGGGCCACTATAGATACCGTCATTCT
        ]])
        local seq4 = model.Sequence("g4&c&l", [[
GTAATAATGTGCGCTTTTGTATTTTCGCAAGGCGACCAATTGACTGTGCCTTTTTTTTTT
GAACGATAACATAGCGGTGCGTGCGAGGAGCCCATGGGCCACTATAGATACCGTCATTCT
        ]])
        local block1 = model.Block({
            model.Fragment(seq1, 0, seq1:length() - 1, 1),
            model.Fragment(seq2, 0, seq2:length() - 1, 1),
        })
        local block2 = model.Block({
            model.Fragment(seq3, 0, seq3:length() - 1, 1),
            model.Fragment(seq4, 0, seq4:length() - 1, 1),
        })
        --
        local algo = require 'npge.algo'
        local function check(...)
            local bs = model.BlockSet(...)
            bs = algo.GiveNames(algo.Cover(bs))
            return algo.CheckPangenome(bs)
        end
        --
        assert.truthy(check({seq1, seq2, seq3, seq4},
            {block1, block2}))
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

    it("no joined blocks can be formed (control)", function()
        local model = require 'npge.model'
        local seq1 = model.Sequence("g1&c&l",
            rand100n1 ..  --> left
            AAA100 ..     --> bad part
            rand100n2)    --> right
        local seq2 = model.Sequence("g2&c&l",
            rand100n1 ..  --> left
            CCC100 ..     --> bad part
            rand100n2)    --> right
        local left = model.Block({
            model.Fragment(seq1, 0, 99, 1),
            model.Fragment(seq2, 0, 99, 1),
        })
        local right = model.Block({
            model.Fragment(seq1, 200, 299, 1),
            model.Fragment(seq2, 200, 299, 1),
        })
        --
        local algo = require 'npge.algo'
        local function check(...)
            local bs = model.BlockSet(...)
            bs = algo.GiveNames(algo.Cover(bs))
            return algo.CheckPangenome(bs)
        end
        --
        assert.truthy(check({seq1, seq2}, {left, right}))
    end)

    it("no joined blocks can be formed (control's control)",
    function()
        -- cyclic sequences => joined block of parted fragments
        local model = require 'npge.model'
        local seq1 = model.Sequence("g1&c&c",
            rand100n1 ..  --> left
            AAA100 ..     --> bad part
            rand100n2)    --> right
        local seq2 = model.Sequence("g2&c&c",
            rand100n1 ..  --> left
            CCC100 ..     --> bad part
            rand100n2)    --> right
        local left = model.Block({
            model.Fragment(seq1, 0, 99, 1),
            model.Fragment(seq2, 0, 99, 1),
        })
        local right = model.Block({
            model.Fragment(seq1, 200, 299, 1),
            model.Fragment(seq2, 200, 299, 1),
        })
        --
        local algo = require 'npge.algo'
        local function check(...)
            local bs = model.BlockSet(...)
            bs = algo.GiveNames(algo.Cover(bs))
            return algo.CheckPangenome(bs)
        end
        --
        assert.falsy(check({seq1, seq2}, {left, right}))
    end)

    it("no blocks can be extended", function()
        local model = require 'npge.model'
        local seq1 = model.Sequence("g1&c&c", rand600)
        local seq2 = model.Sequence("g2&c&c", rand600)
        local block = model.Block({
            model.Fragment(seq1, 10, 590, 1),
            model.Fragment(seq2, 10, 590, 1),
        })
        --
        local algo = require 'npge.algo'
        local function check(...)
            local bs = algo.GiveNames(algo.Cover(
                model.BlockSet(...)))
            return algo.CheckPangenome(bs)
        end
        --
        assert.falsy(check({seq1, seq2}, {block}))
    end)

    it("no blocks can be extended (control)", function()
        local model = require 'npge.model'
        local seq1 = model.Sequence("g1&c&c", rand600)
        local seq2 = model.Sequence("g2&c&c",
            rand600_bad_ends_10)
        local block = model.Block({
            model.Fragment(seq1, 10, 589, 1),
            model.Fragment(seq2, 10, 589, 1),
        })
        --
        local algo = require 'npge.algo'
        local function check(...)
            local bs = algo.GiveNames(algo.Cover(
                model.BlockSet(...)))
            return algo.CheckPangenome(bs)
        end
        --
        assert.truthy(check({seq1, seq2}, {block}))
    end)

    it("real pangenome #mosses passes the check", function()
        -- https://travis-ci.org/npge/lua-npge/jobs/63467470
        if os.getenv('UNDER_VALGRIND') then
            return
        end
        local bad = dofile('spec/sample_pangenome.lua')
        local good = dofile('spec/sample_pangenome2.lua')
        local algo = require 'npge.algo'
        assert.falsy(algo.CheckPangenome(bad))
        assert.truthy(algo.CheckPangenome(good))
    end)
end)
