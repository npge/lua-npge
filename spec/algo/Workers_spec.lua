-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2016 Boris Nagaev
-- See the LICENSE file for terms of use.

describe("npge.algo.Workers", function()
    it("extracts good blocks in parallel",
    function()
        local config = require 'npge.config'
        local revert = config:updateKeys({
            util = {WORKERS = 4},
        })
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
        local blocks = {}
        local N = 1000
        for i = 1, N do
            local block = Block({f1, f2})
            table.insert(blocks, block)
        end
        local BlockSet = require 'npge.model.BlockSet'
        local blockset = BlockSet({s1, s2}, blocks)
        --
        local Workers = require 'npge.algo.Workers'
        local good_blocks = Workers.GoodSubblocks(blockset)
        assert.truthy(#good_blocks:blocks() >= N)
        local isGood = require 'npge.block.isGood'
        assert.truthy(isGood(good_blocks:blocks()[1]))
        --
        revert()
    end)

    it("works if number of workers is 1",
    function()
        local config = require 'npge.config'
        local revert = config:updateKeys({
            util = {WORKERS = 1},
        })
        --
        local BlockSet = require 'npge.model.BlockSet'
        local blockset = BlockSet({}, {})
        --
        local Workers = require 'npge.algo.Workers'
        local good_blocks = Workers.GoodSubblocks(blockset)
        assert.equal(#good_blocks:blocks(), 0)
        --
        revert()
    end)

    it("returns the same blocks",
    function()
        local config = require 'npge.config'
        local revert = config:updateKeys({
            util = {WORKERS = 4},
        })
        --
        local model = require 'npge.model'
        local BlockSet = model.BlockSet
        local s1 = model.Sequence('s1', 'ACTG')
        local s2 = model.Sequence('s2', 'CTG')
        local b1 = model.Block({
            model.Fragment(s1, 1, 1, 1),
        })
        local b2 = model.Block({
            model.Fragment(s1, 2, 2, 1),
        })
        local blockset = BlockSet({s1, s2}, {b1, b2})
        --
        local Workers = require 'npge.algo.Workers'
        local bs = Workers.applyToBlockset(blockset,
            "return ...", Workers.mapBlocks)
        assert.equal(bs, blockset)
        --
        revert()
    end)

    it("returns the same sequences", function()
        local config = require 'npge.config'
        local revert = config:updateKeys({
            util = {WORKERS = 4},
        })
        --
        local model = require 'npge.model'
        local BlockSet = model.BlockSet
        local s1 = model.Sequence('s1', 'ACTG')
        local s2 = model.Sequence('s2', 'CTG')
        local s3 = model.Sequence('s3', 'CTG')
        local s4 = model.Sequence('s4', 'CTG')
        local blockset = BlockSet({s1, s2, s3, s4}, {})
        --
        local Workers = require 'npge.algo.Workers'
        local bs = Workers.applyToBlockset(blockset,
            "return ...", Workers.mapSequences)
        assert.equal(bs, blockset)
        --
        revert()
    end)

    it("covers sequences", function()
        local config = require 'npge.config'
        local revert = config:updateKeys({
            util = {WORKERS = 4},
        })
        --
        local model = require 'npge.model'
        local BlockSet = model.BlockSet
        local s1 = model.Sequence('s1', 'ACTG')
        local s2 = model.Sequence('s2', 'CTG')
        local s3 = model.Sequence('s3', 'CTG')
        local s4 = model.Sequence('s4', 'CTG')
        local blockset = BlockSet({s1, s2, s3, s4}, {})
        --
        local Workers = require 'npge.algo.Workers'
        local bs = Workers.applyToBlockset(blockset, [[
            local Cover = require 'npge.algo.Cover'
            return Cover(...)
            ]], Workers.mapSequences)
        local Cover = require 'npge.algo.Cover'
        assert.equal(bs, Cover(blockset))
        --
        revert()
    end)

    it("catches errors thrown in threads",
    function()
        local config = require 'npge.config'
        local revert = config:updateKeys({
            util = {WORKERS = 4},
        })
        --
        local model = require 'npge.model'
        local BlockSet = model.BlockSet
        local s1 = model.Sequence('s1', 'ACTG')
        local s2 = model.Sequence('s2', 'CTG')
        local b1 = model.Block({
            model.Fragment(s1, 1, 1, 1),
        })
        local b2 = model.Block({
            model.Fragment(s1, 2, 2, 1),
        })
        local blockset = BlockSet({s1, s2}, {b1, b2})
        --
        local Workers = require 'npge.algo.Workers'
        assert.has_error(function()
            Workers.applyToBlockset(blockset,
                "error('test')", Workers.mapBlocks)
        end)
        --
        revert()
    end)

    it("catches errors thrown in threads (in #iterators)",
    function()
        local config = require 'npge.config'
        local revert = config:updateKeys({
            util = {WORKERS = 4},
        })
        --
        local N = 100
        local model = require 'npge.model'
        local BlockSet = model.BlockSet
        local seqs = {}
        for i = 1, N do
            table.insert(seqs, model.Sequence('s' .. i, 'CTG'))
        end
        local fragments = {}
        for i = 1, N do
            local s = seqs[math.random(1, N)]
            table.insert(fragments, model.Fragment(s, 1, 1, 1))
        end
        local blocks = {}
        for i = 1, N do
            local for_block = {}
            for j = 1, 10 do
                local f = fragments[math.random(1, N)]
                table.insert(for_block, f)
            end
            table.insert(blocks, model.Block(for_block))
        end
        local blockset = model.BlockSet(seqs, blocks)
        --
        local Workers = require 'npge.algo.Workers'
        assert.has_error(function()
            Workers.applyToBlockset(blockset, [[
            local blockset = ...
            for block in blockset:iterBlocks() do
                error('test')
            end
            return blockset
            ]], Workers.mapBlocks)
        end)
        assert.has_error(function()
            Workers.applyToBlockset(blockset, [[
            local blockset = ...
            for block in blockset:iterBlocks() do
                for fragment in block:iterFragments() do
                    error('test')
                end
            end
            return blockset
            ]], Workers.mapBlocks)
        end)
        assert.has_error(function()
            Workers.applyToBlockset(blockset, [[
            local blockset = ...
            for sequence in blockset:iterSequences() do
                error('test')
            end
            return blockset
            ]], Workers.mapBlocks)
        end)
        --
        revert()
    end)

    it("finds hits using blast+ with multiple workers",
    function()
        local Sequence = require 'npge.model.Sequence'
        local s1 = Sequence('s1', string.rep('ATGC', 100))
        local s2 = Sequence('s2', string.rep('ATGC', 100))
        local BlockSet = require 'npge.model.BlockSet'
        local bs_with_seqs = BlockSet({s1, s2}, {})
        local BlastHits = require 'npge.algo.BlastHits'
        local W = require 'npge.algo.Workers'
        local hits1 = BlastHits(bs_with_seqs, bs_with_seqs)
        local hits2 = W.BlastHits(bs_with_seqs, bs_with_seqs)
        assert.equal(hits1, hits2)
    end)

    it("unwinds from consensus with multiple workers",
    function()
        local config = require 'npge.config'
        local revert = config:updateKeys({
            util = {WORKERS = 4},
        })
        --
        local model = require 'npge.model'
        local algo = require 'npge.algo'
        local text = ("AATAT"):rep(100) -- length = 500
        local seqs = {}
        for i = 1, 10 do
            seqs[i] = model.Sequence('s' .. i, text)
        end
        local for_block = {}
        for i = 0, 99 do
            local seqi = math.floor(i / 10) + 1
            local framei = i % 10 + 1
            local seq = seqs[seqi]
            local start = framei * 30
            local stop = start + 10
            local f = model.Fragment(seq, start, stop, 1)
            if not for_block[framei] then
                for_block[framei] = {}
            end
            table.insert(for_block[framei], f)
        end
        local blocks = {}
        for i, fragments in ipairs(for_block) do
            blocks['block' .. i] = model.Block(fragments)
        end
        local bs = model.BlockSet(seqs, blocks)
        --
        local cs = algo.ConsensusSequences(bs)
        assert.truthy(cs:sequenceByName('block1'))
        assert.truthy(cs:sequenceByName('block10'))
        local cs_covered = algo.Cover(cs)
        --
        local unwound1 = algo.UnwindBlocks(cs_covered,
            {['']=bs})
        local unwound2 = algo.Workers.UnwindBlocks(cs_covered,
            {['']=bs})
        assert.are.equal(unwound1, unwound2)
        --
        revert()
    end)
end)
