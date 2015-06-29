-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

describe("npge.block.goodSubblocks", function()
    it("extracts good parts from block (already good)",
    function()
        local Sequence = require 'npge.model.Sequence'
        local s = Sequence('seq', string.rep('ATGC', 100))
        local Fragment = require 'npge.model.Fragment'
        local f1 = Fragment(s, 0, s:length() - 1, 1)
        local f2 = Fragment(s, 0, s:length() - 1, 1)
        local Block = require 'npge.model.Block'
        local block = Block({f1, f2})
        local isGood = require 'npge.block.isGood'
        assert.truthy(isGood(block))
        local goodSubblocks =
            require 'npge.block.goodSubblocks'
        local gs = goodSubblocks(block)
        assert.same(gs, {block})
    end)

    it("extracts good parts from block (one fragment is bad)",
    function()
        local Sequence = require 'npge.model.Sequence'
        local s = Sequence('seq', string.rep('ATGC', 100))
        local Fragment = require 'npge.model.Fragment'
        local f1 = Fragment(s, 0, s:length() - 1, 1)
        local f2 = Fragment(s, 0, s:length() - 1, 1)
        local f3 = Fragment(s, s:length() - 1, 0, -1)
        local Block = require 'npge.model.Block'
        local block = Block({f1, f2, f3})
        local goodSubblocks =
            require 'npge.block.goodSubblocks'
        local gs = goodSubblocks(block)
        assert.same(gs, {Block({f1, f2})})
    end)

    it("finds identical parts of #MIN_END",
    function()
        local config = require 'npge.config'
        local revert = config:updateKeys({
            general = {
                MIN_LENGTH = 10,
                FRAME_LENGTH = 10,
                MIN_IDENTITY = 0.5,
                MIN_END = 3,
            },
        })
        --
        local Sequence = require 'npge.model.Sequence'
        local s1 = Sequence('s1', "CAAAGCGCGCGCAAAC")
        local s2 = Sequence('s2', "TAAAGGGGGGGGAAAT")
        local Fragment = require 'npge.model.Fragment'
        local f1 = Fragment(s1, 0, s1:length() - 1, 1)
        local f2 = Fragment(s2, 0, s1:length() - 1, 1)
        local Block = require 'npge.model.Block'
        local block = Block({f1, f2})
        local goodSubblocks =
            require 'npge.block.goodSubblocks'
        local gs = goodSubblocks(block)
        assert.same(gs, {Block({
            {Fragment(s1, 1, s1:length() - 1 - 1, 1),
                "AAAGCGCGCGCAAA"},
            {Fragment(s2, 1, s2:length() - 1 - 1, 1),
                "AAAGGGGGGGGAAA"},
        })})
        --
        revert()
    end)

    it("finds identical parts of #MIN_END2",
    function()
        local config = require 'npge.config'
        local revert = config:updateKeys({
            general = {
                MIN_LENGTH = 4,
                FRAME_LENGTH = 4,
                MIN_IDENTITY = 0.5,
                MIN_END = 3,
            },
        })
        --
        local Sequence = require 'npge.model.Sequence'
        local s1 = Sequence('s1',
            "CAAATTTTTTTTAAAACGCGCGCAAAC")
        local s2 = Sequence('s2',
            "GAAAGGGGGGGGAAAAGGGGGGGAAAT")
        local Fragment = require 'npge.model.Fragment'
        local f1 = Fragment(s1, 0, s1:length() - 1, 1)
        local f2 = Fragment(s2, 0, s1:length() - 1, 1)
        local Block = require 'npge.model.Block'
        local block = Block({f1, f2})
        local goodSubblocks =
            require 'npge.block.goodSubblocks'
        local gs = goodSubblocks(block)
        assert.same(gs, {Block({
            {Fragment(s1, 12, 25, 1), "AAAACGCGCGCAAA"},
            {Fragment(s2, 12, 25, 1), "AAAAGGGGGGGAAA"},
        })})
        --
        revert()
    end)

    it("extracts good parts from block (long gap)",
    function()
        -- AAAAAAAAA
        -- AAA---AAA
        local config = require 'npge.config'
        local min_len = config.general.MIN_LENGTH
        local Sequence = require 'npge.model.Sequence'
        local s = Sequence('seq', string.rep('A', min_len * 3))
        local Fragment = require 'npge.model.Fragment'
        local f1 = Fragment(s, 0, s:length() - 1, 1)
        local f2 = Fragment(s, 0, min_len * 2 - 1, 1)
        local Block = require 'npge.model.Block'
        local block = Block({
            {f1, string.rep('A', min_len * 3)},
            {f2, string.rep('A', min_len) ..
                string.rep('-', min_len) ..
                string.rep('A', min_len)},
        })
        local goodSubblocks =
            require 'npge.block.goodSubblocks'
        local gs = goodSubblocks(block)
        assert.truthy(#gs >= 1)
        local isGood = require 'npge.block.isGood'
        assert.truthy(isGood(gs[1]))
    end)

    it("extracts good parts from block (terminal gap)",
    function()
        -- AAAAA
        -- AAA--
        local config = require 'npge.config'
        local min_len = config.general.MIN_LENGTH
        local gap_len = min_len - 1
        local Sequence = require 'npge.model.Sequence'
        local s = Sequence('seq', string.rep('A', min_len * 2))
        local Fragment = require 'npge.model.Fragment'
        local f1 = Fragment(s, 0, s:length() - 1, 1)
        local f2 = Fragment(s, 0, s:length() - gap_len - 1, 1)
        local Block = require 'npge.model.Block'
        local block = Block({
            {f1, string.rep('A', min_len * 2)},
            {f2, string.rep('A', s:length() - gap_len) ..
                string.rep('-', gap_len)},
        })
        local goodSubblocks =
            require 'npge.block.goodSubblocks'
        local gs = goodSubblocks(block)
        assert.truthy(#gs == 1)
        local isGood = require 'npge.block.isGood'
        assert.truthy(isGood(gs[1]))
    end)

    it("finds nothing in block of 1 fragment",
    function()
        local config = require 'npge.config'
        local min_len = config.general.MIN_LENGTH
        local Sequence = require 'npge.model.Sequence'
        local s = Sequence('seq', string.rep('A', min_len * 2))
        local Fragment = require 'npge.model.Fragment'
        local f1 = Fragment(s, 0, s:length() - 1, 1)
        local Block = require 'npge.model.Block'
        local block = Block({f1})
        local goodSubblocks =
            require 'npge.block.goodSubblocks'
        local gs = goodSubblocks(block)
        assert.truthy(#gs == 0)
    end)

    it("extracts good parts from block (opening gap)",
    function()
        -- AAAAA
        -- --AAA
        local config = require 'npge.config'
        local min_len = config.general.MIN_LENGTH
        local gap_len = min_len - 1
        local Sequence = require 'npge.model.Sequence'
        local s = Sequence('seq', string.rep('A', min_len * 2))
        local Fragment = require 'npge.model.Fragment'
        local f1 = Fragment(s, 0, s:length() - 1, 1)
        local f2 = Fragment(s, 0, s:length() - gap_len - 1, 1)
        local Block = require 'npge.model.Block'
        local block = Block({
            {f1, string.rep('A', min_len * 2)},
            {f2, string.rep('-', gap_len) ..
                string.rep('A', s:length() - gap_len)},
        })
        local goodSubblocks =
            require 'npge.block.goodSubblocks'
        local gs = goodSubblocks(block)
        assert.truthy(#gs == 1)
        local isGood = require 'npge.block.isGood'
        assert.truthy(isGood(gs[1]))
    end)

    it("extracts good parts from block (opening gap in 1st fr)",
    function()
        -- --AAA
        -- AAAAA
        local config = require 'npge.config'
        local min_len = config.general.MIN_LENGTH
        local gap_len = min_len - 1
        local Sequence = require 'npge.model.Sequence'
        local s = Sequence('seq', string.rep('A', min_len * 2))
        local Fragment = require 'npge.model.Fragment'
        local f1 = Fragment(s, 0, s:length() - 1, 1)
        local f2 = Fragment(s, 0, s:length() - gap_len - 1, 1)
        local Block = require 'npge.model.Block'
        local block = Block({
            {f2, string.rep('-', gap_len) ..
                string.rep('A', s:length() - gap_len)},
            {f1, string.rep('A', min_len * 2)},
        })
        local goodSubblocks =
            require 'npge.block.goodSubblocks'
        local gs = goodSubblocks(block)
        assert.truthy(#gs == 1)
        local isGood = require 'npge.block.isGood'
        assert.truthy(isGood(gs[1]))
    end)

    it("extracts good parts from block (terminal long gap)",
    function()
        -- AAAAAA
        -- AAA---
        local config = require 'npge.config'
        local min_len = config.general.MIN_LENGTH
        local gap_len = min_len
        local Sequence = require 'npge.model.Sequence'
        local s = Sequence('seq', string.rep('A', min_len * 2))
        local Fragment = require 'npge.model.Fragment'
        local f1 = Fragment(s, 0, s:length() - 1, 1)
        local f2 = Fragment(s, 0, s:length() - gap_len - 1, 1)
        local Block = require 'npge.model.Block'
        local block = Block({
            {f1, string.rep('A', min_len * 2)},
            {f2, string.rep('A', s:length() - gap_len) ..
                string.rep('-', gap_len)},
        })
        local goodSubblocks =
            require 'npge.block.goodSubblocks'
        local gs = goodSubblocks(block)
        assert.truthy(#gs == 1)
        local isGood = require 'npge.block.isGood'
        assert.truthy(isGood(gs[1]))
    end)

    it("extracts good parts from block (mismatches in middle)",
    function()
        -- AAAAAAAA
        -- AAATTAAA
        local config = require 'npge.config'
        local min_len = config.general.MIN_LENGTH
        local good_len = 2 * min_len
        local min_ident = config.general.MIN_IDENTITY
        -- ident = good_len / (good_len + middle_len)
        local middle_len = good_len / min_ident - good_len
        middle_len = math.floor(middle_len) + 2
        local length = good_len + middle_len
        local Sequence = require 'npge.model.Sequence'
        local s1 = Sequence('s1', string.rep('A', length))
        local s2 = Sequence('s2', string.rep('A', min_len) ..
            string.rep('T', middle_len) ..
            string.rep('A', min_len))
        assert(s1:length() == s2:length())
        local Fragment = require 'npge.model.Fragment'
        local f1 = Fragment(s1, 0, s1:length() - 1, 1)
        local f2 = Fragment(s2, 0, s2:length() - 1, 1)
        local Block = require 'npge.model.Block'
        local block = Block({f1, f2})
        local isGood = require 'npge.block.isGood'
        assert.falsy(isGood(block))
        local goodSubblocks =
            require 'npge.block.goodSubblocks'
        local gs = goodSubblocks(block)
        assert.truthy(#gs >= 1)
        assert.truthy(isGood(gs[1]))
    end)

    it("extracts good parts from block (gaps in middle)",
    function()
        -- AAAAAAAA
        -- AAA--AAA
        local config = require 'npge.config'
        local min_len = config.general.MIN_LENGTH
        local good_len = 2 * min_len
        local min_ident = config.general.MIN_IDENTITY
        -- roughly 2 * middle_len for mismatches
        local middle_len = good_len / min_ident - good_len
        middle_len = math.floor(middle_len) + 2
        middle_len = middle_len * 2.5
        local length = good_len + middle_len
        local Sequence = require 'npge.model.Sequence'
        local s1 = Sequence('s1', string.rep('A', length))
        local Fragment = require 'npge.model.Fragment'
        local f1 = Fragment(s1, 0, s1:length() - 1, 1)
        local f2 = Fragment(s1, 0,
            s1:length() - middle_len - 1, 1)
        local Block = require 'npge.model.Block'
        local block = Block({
            {f1, string.rep('A', length)},
            {f2, string.rep('A', min_len) ..
                string.rep('-', middle_len) ..
                string.rep('A', min_len)},
        })
        local isGood = require 'npge.block.isGood'
        assert.falsy(isGood(block))
        local goodSubblocks =
            require 'npge.block.goodSubblocks'
        local gs = goodSubblocks(block)
        assert.truthy(#gs >= 1)
        assert.truthy(isGood(gs[1]))
    end)

    it("extracts good parts from block (gaps in groups)",
    function()
        -- AAAAAAAA
        -- A-ATTA-A
        local config = require 'npge.config'
        local min_len = config.general.MIN_LENGTH
        local good_len = 2 * min_len
        local min_ident = config.general.MIN_IDENTITY
        -- ident = good_len / (good_len + middle_len)
        local middle_len = good_len / min_ident - good_len
        middle_len = math.floor(middle_len) + 2
        local length = good_len + middle_len
        local Sequence = require 'npge.model.Sequence'
        local s1 = Sequence('s1', string.rep('A', length))
        local s2 = Sequence('s2',
            string.rep('A', min_len - 1) ..
            string.rep('T', middle_len) ..
            string.rep('A', min_len - 1))
        local pregap = math.floor(min_len / 2)
        local postgap = min_len - 1 - pregap
        local Fragment = require 'npge.model.Fragment'
        local f1 = Fragment(s1, 0, s1:length() - 1, 1)
        local f2 = Fragment(s2, 0, s2:length() - 1, 1)
        local Block = require 'npge.model.Block'
        local A_A = string.rep('A', pregap) .. '-' ..
            string.rep('A', postgap)
        local block = Block({
            {f1, s1:text()},
            {f2, A_A .. string.rep('T', middle_len) .. A_A},
        })
        local isGood = require 'npge.block.isGood'
        assert.falsy(isGood(block))
        local goodSubblocks =
            require 'npge.block.goodSubblocks'
        local gs = goodSubblocks(block)
        assert.truthy(#gs >= 1)
        assert.truthy(isGood(gs[1]))
    end)

    it("extracts good parts from block (mismatches in groups)",
    function()
        -- AAAAAAAA
        -- ACATTACA
        local config = require 'npge.config'
        local min_len = config.general.MIN_LENGTH
        local good_len = 2 * min_len
        local min_ident = config.general.MIN_IDENTITY
        -- ident = good_len / (good_len + middle_len)
        local middle_len = good_len / min_ident - good_len
        middle_len = math.floor(middle_len) + 2
        local length = good_len + middle_len
        local Sequence = require 'npge.model.Sequence'
        local s1 = Sequence('s1', string.rep('A', length))
        local s2 = Sequence('s2',
            string.rep('A', min_len) ..
            string.rep('T', middle_len) ..
            string.rep('A', min_len))
        local Fragment = require 'npge.model.Fragment'
        local f1 = Fragment(s1, 0, s1:length() - 1, 1)
        local f2 = Fragment(s2, 0, s2:length() - 1, 1)
        local Block = require 'npge.model.Block'
        local block = Block({f1, f2})
        local isGood = require 'npge.block.isGood'
        assert.falsy(isGood(block))
        local goodSubblocks =
            require 'npge.block.goodSubblocks'
        local gs = goodSubblocks(block)
        assert.truthy(#gs >= 1)
        assert.truthy(isGood(gs[1]))
    end)

    it("extracts good parts from block (whole block is bad)",
    function()
        -- AAA
        -- CCC
        local config = require 'npge.config'
        local min_len = config.general.MIN_LENGTH
        local Sequence = require 'npge.model.Sequence'
        local s1 = Sequence('s1', string.rep('A', min_len))
        local s2 = Sequence('s2', string.rep('C', min_len))
        local Fragment = require 'npge.model.Fragment'
        local f1 = Fragment(s1, 0, s1:length() - 1, 1)
        local f2 = Fragment(s2, 0, s2:length() - 1, 1)
        local Block = require 'npge.model.Block'
        local block = Block({f1, f2})
        local isGood = require 'npge.block.isGood'
        assert.falsy(isGood(block))
        local goodSubblocks =
            require 'npge.block.goodSubblocks'
        local gs = goodSubblocks(block)
        assert.same(gs, {})
    end)

    it("extracts good parts from block (#one_gap near the end)",
    function()
        local config = require 'npge.config'
        local revert = config:updateKeys({
            general = {
                MIN_LENGTH = 60,
                FRAME_LENGTH = 60,
                MIN_END = 3,
            },
        })
        --
        local Sequence = require 'npge.model.Sequence'
        local s1 = Sequence('s1', [[
TACGTATTGTGAATCTCTGGGGTGGCTGGTGATTGCGCAAACAAACTCACTCTGTAGGGA
GGCaAA
        ]])
        local s2 = Sequence('s2', [[
TACGTATTGTGAATCTCTGGGGTGGCTGGTGATTGCGCAAACAAACTCACTCTGTAGGGA
GGCgAA
        ]])
        local Fragment = require 'npge.model.Fragment'
        local f1 = Fragment(s1, 0, s1:length() - 1, 1)
        local f2 = Fragment(s2, 0, s2:length() - 1, 1)
        local Block = require 'npge.model.Block'
        local block = Block({f1, f2})
        local isGood = require 'npge.block.isGood'
        assert.falsy(isGood(block))
        local goodSubblocks =
            require 'npge.block.goodSubblocks'
        local gs = goodSubblocks(block)
        assert.equal(#gs, 1)
        assert.equal(gs[1], Block({
            Fragment(s1, 0, s1:length() - 3 - 1, 1),
            Fragment(s2, 0, s2:length() - 3 - 1, 1),
        }))
        --
        revert()
    end)

    it("extracts good parts from block (real example)",
    function()
        local config = require 'npge.config'
        local revert = config:updateKeys({
            general = {
                MIN_LENGTH = 100,
                FRAME_LENGTH = 100,
                MIN_END = 3,
                MIN_IDENTITY = 0.9,
            },
        })
        --
        local t1 = [[
ATTTTGTTAAGAGCTGTGGTTCGACGTGACGCTAAAGAAGTTATATGATAAGTAGAGGGA
CTCATAATTGAAAGTGCGTTTTTTTTTATCACTTGTGAGACACTAATTTCTCCTAAGGAA
CATACATAAGATTTATTCAGTCGTTTTAATTGATTAGCATTTAAGCTTTTTACCATTTCG
TTACAC]]
        local t2 = [[
ATTTTGTTGAGAACGATGCTTTGACGTAAAGCTAGAAAAGTGTGATGATAAGTAGAGGGA
CTCATGGTTGAGAGTGCGTTTTTTTTGATTATTTGTGAGACACTAATTTCTCCCAAGAAA
CATACATAAGATTTATTCATTTTTTTCAATTGATTAGCATTTAAGCTTTTAATGGCTATA
TCTTGC]]
        local model = require 'npge.model'
        local s1 = model.Sequence('s1', t1)
        local s2 = model.Sequence('s2', t2)
        local f1 = model.Fragment(s1, 0, s1:length() - 1, 1)
        local f2 = model.Fragment(s2, 0, s2:length() - 1, 1)
        local block = model.Block({{f1, t1}, {f2, t2}})
        local goodSubblocks = require 'npge.block.goodSubblocks'
        local subblocks = goodSubblocks(block)
        local consensus = require 'npge.block.consensus'
        assert.equal(#subblocks, 1)
        assert.equal(consensus(subblocks[1]), (([[
        TTGAAAGTGCGTTTTTTTTTATTATTTGTGAGACACTAATTTCTCCTAAGAA
        ACATACATAAGATTTATTCATTTTTTTTAATTGATTAGCA
        TTTAAGCTTTT]]):gsub('%s', '')))
        --
        revert()
    end)

    it("extracts good parts from block (real example 2)",
    function()
        local config = require 'npge.config'
        local revert = config:updateKeys({
            general = {
                MIN_LENGTH = 100,
                FRAME_LENGTH = 100,
                MIN_END = 3,
                MIN_IDENTITY = 0.9,
            },
        })
        --
        local t1 = [[
TTTTTTTTGTACCGAAAATAGAAAAAATGGCTAAGTAACATAAAGGTAAT
GTATTGGATTGCAAATCCTAGAAAGATGGTTCAAATCCGTCCTTAGCCTA
CTTGA-AATTCTACTGTTTCTCTACAAGTACTGCAC]]
        local t2 = [[
TTTCTCCTGCACTAAAAGTCTAAAAAATGGCTAAGTAACATAAAGGTAAT
GTATTGGATTGCAAATCCTAGAAAGATGGTTCAAATCCGTCCTTAGCCTA
CTTTACAATTATACCGTTTTCGTATAAGTGCTGCAC]]
        local model = require 'npge.model'
        local s1 = model.Sequence('s1', t1)
        local s2 = model.Sequence('s2', t2)
        local f1 = model.Fragment(s1, 0, s1:length() - 1, 1)
        local f2 = model.Fragment(s2, 0, s2:length() - 1, 1)
        local block = model.Block({{f1, t1}, {f2, t2}})
        local goodSubblocks = require 'npge.block.goodSubblocks'
        local subblocks = goodSubblocks(block)
        --
        assert.equal(#subblocks, 1)
        assert.equal(subblocks[1]:length(),
            #(t1:gsub('%s', '')))
        --
        revert()
    end)

    it("extracts good parts (real example, cuts bad #ends)",
    function()
        local config = require 'npge.config'
        local revert = config:updateKeys({
            general = {
                MIN_LENGTH = 100,
                FRAME_LENGTH = 100,
                MIN_END = 10,
                MIN_IDENTITY = 0.7,
            },
        })
        --
        local t1 = [[
AAAAGTATTCTGCAGCGCCAAAGCCTTTATTATGATTATATCGCGGGATAGAGTAATTGG
TAACTCGTCAGGCTCATAATCTGAATGTTGTAGGTTCGAATCTTACTCCCGCCAAATGTT
ATAAGTCGTGTTTGTTAAACAGCAGGATGTATAAAGTAGTGCATCTATCACTTGGTCGTT
TCCGCGCGCCCTTGATCTTAGAAAAT]]
        local t2 = [[
AAAAAAAGAATATTTTGCAGTTGAATAAACTCTATTATGCTCGCGGGATAGAGTAATTGG
TAACTCGTCAGGCTCATAATCTGAATGTTGTAGGTTCAAATCCTATTCCCGCCAAATGTT
ATAAGT-GTTTTTGGTAAATAGTGGAATCTAGAAAGCAGTGCATCTATTACTTGCTCGTT
TTTGTGCGCTTTTTCTTTTCTCAAAT]]
        local model = require 'npge.model'
        local s1 = model.Sequence('s1', t1)
        local s2 = model.Sequence('s2', t2)
        local f1 = model.Fragment(s1, 0, s1:length() - 1, 1)
        local f2 = model.Fragment(s2, 0, s2:length() - 1, 1)
        local block = model.Block({{f1, t1}, {f2, t2}})
        local goodSubblocks = require 'npge.block.goodSubblocks'
        local subblocks = goodSubblocks(block)
        --
        assert.equal(#subblocks, 1)
        local subblock = subblocks[1]
        assert.equal(subblock:length(), 153)
        local f = subblock:fragments()[1]
        local t = subblock:text(f)
        assert.equal(t:sub(1, 7), 'TCGCGGG')
        assert.equal(t:sub(-2), 'TT')
        --
        revert()
    end)

    it("does not #freeze", function()
        local config = require 'npge.config'
        local revert = config:updateKeys({
            general = {
                MIN_LENGTH = 50,
                FRAME_LENGTH = 200,
                MIN_END = 10,
                MIN_IDENTITY = 0.65,
            },
        })
        --
        local t1 = [[
AAAAGAGTAGATACGCCCTGTGCTCTTCATTCTTTGGACTAGGATTGCATGGCCC-G---
--AAGCAGC----ATAA----TGCGATAGTAGC----AAAGACTTGAGTGAATTTTTGGT
CTATGTCAGTTAGTGAGAGCC----TACCTCGCAG---------CCTTTCCAATTATGCC
TGTGAATGCCCTTACTATTAC---ACAATAACGGC---------TTCAGTCGCTATTATG
AATATCACGTTGGCGCAGGGCGCTCTAATAATCTACTCCGTTTGAACTTCATACATAAAC
AGTTACTTCTATCGTGT----TGCC----CCAT----------CGGGGCCAGGTTAAAGG
GCGCATGAGGCGAATTATCATCCAACAGCCAGGGAAATGAGCGGCAGATTGGTAGAACAG
CGGATTAATAATTCGCATGTCGGAATAGTTTAGTCGGTTAGAACAGCGGGATCATAATTC
GCACACGGGGGTTCAAATCCCTCTTCCGATAGGAACTTTCGGATAAGA-ATTGAACCTAC
GGGAGGCAAAAAAAAGATATATATATCGTTTTTTTGCTGGTCACTAACCTTATCCTAAAT
CTCCTTCTTCTATCACAGAACACGGTAAAGAAAGATTTACCATGGATAACTAGAAATGCA
ACATAATCAATCAATCATCATAGATAATTCATTAAAATACATAGAGACTCAAATTGCTAA
AATACATAGAGACTCAAATTGCATAGAACGGCGGCATCACCTTTAGGTTTCATTCTAGAT
CTTGTTCACGAACGTT----------GTGGCTATACTCTTATGTTCTATCAACAAAGTAG
AATTAGCCGTTATGCTAGTAGCTTATGAATCATCATAGATAATTCATTGTTGTAGCTCCA
CAAATGGGAACGCGCGCGAATG---GTTCGTTGCT--CCGGCTTGCTGCAGGAGAAATTG
AAGTAGGTCTACATGGCTTGCT]]
        local t2 = [[
AAAATTGTAGATACGCCGTGTGCTCTTCATTCTTTGGACTATAGTTACATAGCCCAGAGG
TAAAGCGGCTGGTATAAAGGCTGCAATATTAGCCTTTAAAGGCTTGATTGAAGTTTTGGC
CTATGTCAGTCAG----AGCCGTTGTGCCCCGCAGTACTGCATGCCTTTCTAATTACGCT
CGTGAATGCCTTTACTACTACTATATAATAACGGCAGTCACAAGTTCAGTCGCAATTAGA
AATATGACCAAGGCATAAGGCGCTTTAATCATCCATTCCGTTCGAACTCTATACATACAC
AGTTACTCCTATCGTTCAGAATGACGAAGCCATATCTTTTTTACGGGACCAGGCCACAGG
GC--ATGAAGCGAATTATCATCCAACAGCCAGG-AAA----CGGCAGATTAGTAGAACAG
CGGAATAATAATTCGCATGTCGGAATAGTTTAGTTGGTTAGAACAGCGGGATCATAATTC
GCACACGGGGGTTCAAATCCCTCTTCCGATAGGAA-TTTAACCTACGGCATAGT------
GGGAGGCAAAGAAAAGATATATATAT-GTTCTTTTGCTGGTCACTAACCTTACCCTAAAT
CTCCCTCT---ATGATAAGCTATGGTAAAGAAAGATTTACGATGTTTCT-TAG-------
-CATAA-CTATAAATC-------------CA-------ACATAATGAATGTTGTT-CTGA
----CAAAGCGA-TCAA-T--CATATA----CAGTA-CACCTTTAGGTTTAATTATAGAT
CTTGTTCACAAACTACATAAACAAGAGTTGCTATACTCTCATTTTATGTCAACAAAATAT
AATTAGTCGCGATGCCAGTAGCTTATGAATCATCTATGATGATTCATTGTTGCAGCTCCG
CGAATGGGAGCGCATGCAAATGTACGTTGCTTGCTCGCCAGCTCGTCGCAGGATAGATTT
AACTAAGTCTAAATGGCTTGCT]]
        local model = require 'npge.model'
        local s1 = model.Sequence('s1', t1)
        local s2 = model.Sequence('s2', t2)
        local f1 = model.Fragment(s1, 0, s1:length() - 1, 1)
        local f2 = model.Fragment(s2, 0, s2:length() - 1, 1)
        local block = model.Block({{f1, t1}, {f2, t2}})
        local goodSubblocks = require 'npge.block.goodSubblocks'
        local subblocks = goodSubblocks(block)
        --
        assert.equal(#subblocks, 2)
        revert()
    end)
end)
