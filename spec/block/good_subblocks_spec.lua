describe("block.good_subblocks", function()
    it("extracts good parts from block (already good)",
    function()
        local Sequence = require 'npge.model.Sequence'
        local s = Sequence('seq', string.rep('ATGC', 100))
        local Fragment = require 'npge.model.Fragment'
        local f1 = Fragment(s, 0, s:length() - 1, 1)
        local f2 = Fragment(s, 0, s:length() - 1, 1)
        local Block = require 'npge.model.Block'
        local block = Block({f1, f2})
        local is_good = require 'npge.block.is_good'
        assert.truthy(is_good(block))
        local good_subblocks =
            require 'npge.block.good_subblocks'
        local gs = good_subblocks(block)
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
        local good_subblocks =
            require 'npge.block.good_subblocks'
        local gs = good_subblocks(block)
        assert.same(gs, {Block({f1, f2})})
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
        local good_subblocks =
            require 'npge.block.good_subblocks'
        local gs = good_subblocks(block)
        assert.truthy(#gs >= 1)
        local is_good = require 'npge.block.is_good'
        assert.truthy(is_good(gs[1]))
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
        local good_subblocks =
            require 'npge.block.good_subblocks'
        local gs = good_subblocks(block)
        assert.truthy(#gs == 1)
        local is_good = require 'npge.block.is_good'
        assert.truthy(is_good(gs[1]))
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
        local good_subblocks =
            require 'npge.block.good_subblocks'
        local gs = good_subblocks(block)
        assert.truthy(#gs == 1)
        local is_good = require 'npge.block.is_good'
        assert.truthy(is_good(gs[1]))
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
        local is_good = require 'npge.block.is_good'
        assert.falsy(is_good(block))
        local good_subblocks =
            require 'npge.block.good_subblocks'
        local gs = good_subblocks(block)
        assert.truthy(#gs >= 1)
        assert.truthy(is_good(gs[1]))
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
        local is_good = require 'npge.block.is_good'
        assert.falsy(is_good(block))
        local good_subblocks =
            require 'npge.block.good_subblocks'
        local gs = good_subblocks(block)
        assert.truthy(#gs >= 1)
        assert.truthy(is_good(gs[1]))
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
        local is_good = require 'npge.block.is_good'
        assert.falsy(is_good(block))
        local good_subblocks =
            require 'npge.block.good_subblocks'
        local gs = good_subblocks(block)
        assert.truthy(#gs >= 1)
        assert.truthy(is_good(gs[1]))
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
        local is_good = require 'npge.block.is_good'
        assert.falsy(is_good(block))
        local good_subblocks =
            require 'npge.block.good_subblocks'
        local gs = good_subblocks(block)
        assert.truthy(#gs >= 1)
        assert.truthy(is_good(gs[1]))
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
        local is_good = require 'npge.block.is_good'
        assert.falsy(is_good(block))
        local good_subblocks =
            require 'npge.block.good_subblocks'
        local gs = good_subblocks(block)
        assert.same(gs, {})
    end)

    it("extracts good parts from block (#one_gap near the end)",
    function()
        local config = require 'npge.config'
        local clone = require 'npge.util.clone'.dict
        local orig = clone(config.general)
        config.general.MIN_LENGTH = 60
        config.general.MIN_END_IDENTICAL_COLUMNS = 3
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
        local is_good = require 'npge.block.is_good'
        assert.falsy(is_good(block))
        local good_subblocks =
            require 'npge.block.good_subblocks'
        local gs = good_subblocks(block)
        assert.equal(#gs, 1)
        assert.equal(gs[1], Block({
            Fragment(s1, 0, s1:length() - 3 - 1, 1),
            Fragment(s2, 0, s2:length() - 3 - 1, 1),
        }))
        --
        config.general = orig
    end)
end)
