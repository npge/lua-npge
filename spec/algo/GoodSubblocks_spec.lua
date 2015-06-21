-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

describe("npge.algo.GoodSubblocks", function()
    it("extracts good blocks of parts (already good)",
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
        local BlockSet = require 'npge.model.BlockSet'
        local blockset = BlockSet({s}, {block})
        local GoodSubblocks = require 'npge.algo.GoodSubblocks'
        assert.same(GoodSubblocks(blockset), blockset)
    end)

    it("extracts good blocks of parts (mismatches in groups)",
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
        local BlockSet = require 'npge.model.BlockSet'
        local blockset = BlockSet({s1, s2}, {block})
        local GoodSubblocks = require 'npge.algo.GoodSubblocks'
        local good_blocks = GoodSubblocks(blockset)
        assert.truthy(#good_blocks:blocks() >= 1)
        assert.truthy(isGood(good_blocks:blocks()[1]))
    end)

    it("no crash on many passes of GoodSubblocks (threads)",
    function()
        -- too slow
        if package.loaded.luacov then
            return
        end
        if os.getenv('UNDER_VALGRIND') then
            return
        end
        --
        local npge = require 'npge'
        local algo = require 'npge.algo'
        local config = require 'npge.config'
        local revert = config:updateKeys({
            general = {MIN_IDENTITY = 0.5},
            util = {WORKERS = 10},
        })
        local bs = dofile 'spec/sample_pangenome.lua'
        bs = npge.model.BlockSet(bs:sequences(), {})
        bs = algo.PrimaryHits(bs)
        local IDENTITIES = {0.5, 0.55, 0.6, 0.65, 0.7, 0.75,
            0.8, 0.85, 0.9, 0.95, 0.97, 0.99}
        for _, identity in ipairs(IDENTITIES) do
            config:updateKeys({
                general = {MIN_IDENTITY = identity},
            })
            bs = npge.algo.Workers.GoodSubblocks(bs)
        end
        revert()
    end)
end)
