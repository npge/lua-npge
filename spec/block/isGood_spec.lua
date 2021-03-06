-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2016 Boris Nagaev
-- See the LICENSE file for terms of use.

describe("npge.block.isGood", function()
    it("checks if a block is good", function()
        local Sequence = require 'npge.model.Sequence'
        local s = Sequence('seq', string.rep('ATGC', 100))
        local Fragment = require 'npge.model.Fragment'
        local f1 = Fragment(s, 0, s:length() - 1, 1)
        local f2 = Fragment(s, 0, s:length() - 1, 1)
        local Block = require 'npge.model.Block'
        local block = Block({f1, f2})
        local isGood = require 'npge.block.isGood'
        assert.truthy(isGood(block))
    end)

    it("checks if a block is bad (1 fragment)", function()
        local Sequence = require 'npge.model.Sequence'
        local s = Sequence('seq', string.rep('ATGC', 100))
        local Fragment = require 'npge.model.Fragment'
        local f1 = Fragment(s, 0, s:length() - 1, 1)
        local Block = require 'npge.model.Block'
        local block = Block({f1})
        local isGood = require 'npge.block.isGood'
        assert.falsy(isGood(block))
    end)

    it("finds block with bad beginning", function()
        local config = require 'npge.config'
        local revert = config:updateKeys({general = {
            MIN_LENGTH = 3,
            FRAME_LENGTH = 3,
            MIN_IDENTITY = 0.6,
            MIN_END = 1,
        }})
        --
        local t1 = "TAATTTTTTTTTTTTTT"
        local t2 = "TTTTTTTTTTTTTTTTT"
        local Sequence = require 'npge.model.Sequence'
        local s1 = Sequence('s1', t1)
        local s2 = Sequence('s2', t2)
        local Fragment = require 'npge.model.Fragment'
        local f1 = Fragment(s1, 0, s1:length() - 1, 1)
        local f2 = Fragment(s2, 0, s2:length() - 1, 1)
        local Block = require 'npge.model.Block'
        local block = Block({f1, f2})
        local isGood = require 'npge.block.isGood'
        assert.falsy(isGood(block))
        --
        revert()
    end)

    it("does not throw if beginning of block is full of gaps",
    function()
        local Sequence = require 'npge.model.Sequence'
        local config = require 'npge.config'
        local length = config.general.MIN_LENGTH
        local gaps = config.general.MIN_END
        local s = Sequence('seq', string.rep('A', length))
        local Fragment = require 'npge.model.Fragment'
        local f1 = Fragment(s, 0, s:length() - 1, 1)
        local f2 = Fragment(s, 0, s:length() - 1, 1)
        local Block = require 'npge.model.Block'
        local block = Block({
            {f1, string.rep('-', gaps) .. s:text()},
            {f2, string.rep('-', gaps) .. s:text()},
        })
        local isGood = require 'npge.block.isGood'
        assert.falsy(isGood(block))
    end)

    it("does not throw if ending of block is full of gaps",
    function()
        local Sequence = require 'npge.model.Sequence'
        local config = require 'npge.config'
        local length = config.general.MIN_LENGTH
        local gaps = config.general.MIN_END
        local s = Sequence('seq', string.rep('A', length))
        local Fragment = require 'npge.model.Fragment'
        local f1 = Fragment(s, 0, s:length() - 1, 1)
        local f2 = Fragment(s, 0, s:length() - 1, 1)
        local Block = require 'npge.model.Block'
        local block = Block({
            {f1, s:text() .. string.rep('-', gaps)},
            {f2, s:text() .. string.rep('-', gaps)},
        })
        local isGood = require 'npge.block.isGood'
        assert.falsy(isGood(block))
    end)

    it("checks if a block is bad (short)", function()
        local Sequence = require 'npge.model.Sequence'
        local config = require 'npge.config'
        local length = config.general.MIN_LENGTH - 1
        local s = Sequence('seq', string.rep('A', length))
        local Fragment = require 'npge.model.Fragment'
        local f1 = Fragment(s, 0, s:length() - 1, 1)
        local f2 = Fragment(s, 0, s:length() - 1, 1)
        local Block = require 'npge.model.Block'
        local block = Block({f1, f2})
        local isGood = require 'npge.block.isGood'
        assert.falsy(isGood(block))
    end)

    it("checks if a block is good (short)", function()
        local Sequence = require 'npge.model.Sequence'
        local config = require 'npge.config'
        local length = config.general.MIN_LENGTH
        local s = Sequence('seq', string.rep('A', length))
        local Fragment = require 'npge.model.Fragment'
        local f1 = Fragment(s, 0, s:length() - 1, 1)
        local f2 = Fragment(s, 0, s:length() - 1, 1)
        local Block = require 'npge.model.Block'
        local block = Block({f1, f2})
        local isGood = require 'npge.block.isGood'
        assert.truthy(isGood(block))
    end)

    it("checks if a block is bad (low identity)", function()
        -- insert non-identical columns in the middle of block
        local Sequence = require 'npge.model.Sequence'
        local config = require 'npge.config'
        local min_ident = config.general.MIN_IDENTITY
        local length = 1000
        local good_cols = math.floor(length * min_ident) - 1
        local bad_cols = length - good_cols
        local first_good_part = math.floor(good_cols / 2)
        local second_good_part = good_cols - first_good_part
        local s1 = Sequence('s1', string.rep('A', length))
        local s2 = Sequence('s2',
            string.rep('A', first_good_part) ..
            string.rep('C', bad_cols) ..
            string.rep('A', second_good_part))
        local Fragment = require 'npge.model.Fragment'
        local f1 = Fragment(s1, 0, length - 1, 1)
        local f2 = Fragment(s2, 0, length - 1, 1)
        local Block = require 'npge.model.Block'
        local block = Block({f1, f2})
        local isGood = require 'npge.block.isGood'
        assert.falsy(isGood(block))
    end)

    it("checks if a block is good (low identity)", function()
        -- insert non-identical columns in the middle of block
        local Sequence = require 'npge.model.Sequence'
        local config = require 'npge.config'
        local min_length = config.general.MIN_LENGTH
        local bad_cols = min_length
        local good_cols = bad_cols * 100
        local length = 2 * good_cols + bad_cols
        local s1 = Sequence('s1', string.rep('A', length))
        local s2 = Sequence('s2',
            string.rep('A', good_cols) ..
            string.rep('C', bad_cols) ..
            string.rep('A', good_cols))
        local Fragment = require 'npge.model.Fragment'
        local f1 = Fragment(s1, 0, length - 1, 1)
        local f2 = Fragment(s2, 0, length - 1, 1)
        local Block = require 'npge.model.Block'
        local block = Block({f1, f2})
        local isGood = require 'npge.block.isGood'
        assert.falsy(isGood(block))
    end)

    it("checks if a block is bad (bad left end)", function()
        -- insert a gap in the column of end, which
        -- is the nearest to the middle of block
        local Sequence = require 'npge.model.Sequence'
        local config = require 'npge.config'
        local min_end = config.general.MIN_END
        local length = 10000
        local s = Sequence('s', string.rep('A', length))
        local row1 = string.rep('A', length)
        local row2 = 'A' .. string.rep('-', min_end - 1) ..
            string.rep('A', length - min_end)
        local Fragment = require 'npge.model.Fragment'
        local f1 = Fragment(s, 0, length - 1, 1)
        local f2 = Fragment(s, 0, length - (min_end - 1) - 1, 1)
        local Block = require 'npge.model.Block'
        local block = Block({
            {f1, row1},
            {f2, row2},
        })
        -- check that identity of the block is enough
        local min_ident = config.general.MIN_IDENTITY
        local identity = require 'npge.block.identity'
        if identity(block) >= min_ident then
            local isGood = require 'npge.block.isGood'
            assert.falsy(isGood(block))
        end
    end)

    it("checks if a block is bad (bad left end, control)",
    function()
        -- insert a gap in the column of end, which
        -- is the nearest to the middle of block
        local Sequence = require 'npge.model.Sequence'
        local config = require 'npge.config'
        local min_end = config.general.MIN_END
        local length = 10000
        local s = Sequence('s', string.rep('A', length))
        local row1 = string.rep('A', length)
        local row2 = string.rep('A', min_end - 1) ..
            '-' .. string.rep('A', length - min_end)
        local Fragment = require 'npge.model.Fragment'
        local f1 = Fragment(s, 0, length - 1, 1)
        local f2 = Fragment(s, 0, length - 1 - 1, 1)
        local Block = require 'npge.model.Block'
        local block = Block({
            {f1, row1},
            {f2, row2},
        })
        -- check that identity of the block is enough
        local min_ident = config.general.MIN_IDENTITY
        local identity = require 'npge.block.identity'
        if identity(block) >= min_ident then
            local isGood = require 'npge.block.isGood'
            assert.truthy(isGood(block))
        end
    end)

    it("checks if a block is good (bad left end)", function()
        -- insert a gap in the column right after the end
        local Sequence = require 'npge.model.Sequence'
        local config = require 'npge.config'
        local min_end = config.general.MIN_END
        local length = 10000
        local s = Sequence('s', string.rep('A', length))
        local row1 = string.rep('A', length)
        local row2 = string.rep('A', min_end) ..
            '-' .. string.rep('A', length - min_end - 1)
        local Fragment = require 'npge.model.Fragment'
        local f1 = Fragment(s, 0, length - 1, 1)
        local f2 = Fragment(s, 0, length - 1 - 1, 1)
        local Block = require 'npge.model.Block'
        local block = Block({
            {f1, row1},
            {f2, row2},
        })
        -- check that identity of the block is enough
        local min_ident = config.general.MIN_IDENTITY
        local identity = require 'npge.block.identity'
        if identity(block) >= min_ident then
            local isGood = require 'npge.block.isGood'
            assert.truthy(isGood(block))
        end
    end)

    it("checks if a block is bad (bad right end)", function()
        -- insert a gap in the column of end, which
        -- is the nearest to the middle of block
        local Sequence = require 'npge.model.Sequence'
        local config = require 'npge.config'
        local min_end = config.general.MIN_END
        local length = 10000
        local s = Sequence('s', string.rep('A', length))
        local row1 = string.rep('A', length)
        local row2 = string.rep('A', length - min_end) ..
            string.rep('-', min_end - 1) .. 'A'
        local Fragment = require 'npge.model.Fragment'
        local f1 = Fragment(s, 0, length - 1, 1)
        local f2 = Fragment(s, 0, length - (min_end-1) - 1, 1)
        local Block = require 'npge.model.Block'
        local block = Block({
            {f1, row1},
            {f2, row2},
        })
        -- check that identity of the block is enough
        local min_ident = config.general.MIN_IDENTITY
        local identity = require 'npge.block.identity'
        if identity(block) >= min_ident then
            local isGood = require 'npge.block.isGood'
            assert.falsy(isGood(block))
        end
    end)

    it("checks if a block is bad (bad right end, control)",
    function()
        -- insert a gap in the column of end, which
        -- is the nearest to the middle of block
        local Sequence = require 'npge.model.Sequence'
        local config = require 'npge.config'
        local min_end = config.general.MIN_END
        local length = 10000
        local s = Sequence('s', string.rep('A', length))
        local row1 = string.rep('A', length)
        local row2 = string.rep('A', length - min_end) ..
            '-' .. string.rep('A', min_end - 1)
        local Fragment = require 'npge.model.Fragment'
        local f1 = Fragment(s, 0, length - 1, 1)
        local f2 = Fragment(s, 0, length - 1 - 1, 1)
        local Block = require 'npge.model.Block'
        local block = Block({
            {f1, row1},
            {f2, row2},
        })
        -- check that identity of the block is enough
        local min_ident = config.general.MIN_IDENTITY
        local identity = require 'npge.block.identity'
        if identity(block) >= min_ident then
            local isGood = require 'npge.block.isGood'
            assert.truthy(isGood(block))
        end
    end)

    it("checks if a block is good (bad right end)", function()
        -- insert a gap in the column right after the end
        local Sequence = require 'npge.model.Sequence'
        local config = require 'npge.config'
        local min_end = config.general.MIN_END
        local length = 10000
        local s = Sequence('s', string.rep('A', length))
        local row1 = string.rep('A', length)
        local row2 = string.rep('A', length - min_end - 1) ..
            '-' .. string.rep('A', min_end)
        local Fragment = require 'npge.model.Fragment'
        local f1 = Fragment(s, 0, length - 1, 1)
        local f2 = Fragment(s, 0, length - 1 - 1, 1)
        local Block = require 'npge.model.Block'
        local block = Block({
            {f1, row1},
            {f2, row2},
        })
        -- check that identity of the block is enough
        local min_ident = config.general.MIN_IDENTITY
        local identity = require 'npge.block.identity'
        if identity(block) >= min_ident then
            local isGood = require 'npge.block.isGood'
            assert.truthy(isGood(block))
        end
    end)

    it("checks if a block is bad (long gap)", function()
        -- insert long gap columns in the middle of block
        local Sequence = require 'npge.model.Sequence'
        local config = require 'npge.config'
        local length = 10000
        local bad_cols = config.general.MIN_LENGTH
        local good_cols = length - bad_cols
        local first_good_part = math.floor(good_cols / 2)
        local second_good_part = good_cols - first_good_part
        local s1 = Sequence('s1', string.rep('A', length))
        local Fragment = require 'npge.model.Fragment'
        local f1 = Fragment(s1, 0, length - 1, 1)
        local f2 = Fragment(s1, 0, length - 1 - bad_cols, 1)
        local row1 = string.rep('A', length)
        local row2 = string.rep('A', first_good_part) ..
            string.rep('-', bad_cols) ..
            string.rep('A', second_good_part)
        local Block = require 'npge.model.Block'
        local block = Block({
            {f1, row1},
            {f2, row2},
        })
        local isGood = require 'npge.block.isGood'
        -- check that identity of the block is enough
        local min_ident = config.general.MIN_IDENTITY
        local identity = require 'npge.block.identity'
        if identity(block) >= min_ident then
            local isGood = require 'npge.block.isGood'
            assert.falsy(isGood(block))
        end
    end)

    it("checks if a block is good (long gap)", function()
        -- insert long gap columns in the middle of block
        local Sequence = require 'npge.model.Sequence'
        local config = require 'npge.config'
        local length = 10000
        local bad_cols = config.general.MIN_LENGTH - 1
        local good_cols = length - bad_cols
        local first_good_part = math.floor(good_cols / 2)
        local second_good_part = good_cols - first_good_part
        local s1 = Sequence('s1', string.rep('A', length))
        local Fragment = require 'npge.model.Fragment'
        local f1 = Fragment(s1, 0, length - 1, 1)
        local f2 = Fragment(s1, 0, length - 1 - bad_cols, 1)
        local row1 = string.rep('A', length)
        local row2 = string.rep('A', first_good_part) ..
            string.rep('-', bad_cols) ..
            string.rep('A', second_good_part)
        local Block = require 'npge.model.Block'
        local block = Block({
            {f1, row1},
            {f2, row2},
        })
        local isGood = require 'npge.block.isGood'
        -- check that identity of the block is enough
        local min_ident = config.general.MIN_IDENTITY
        local identity = require 'npge.block.identity'
        if identity(block) >= min_ident then
            local isGood = require 'npge.block.isGood'
            assert.falsy(isGood(block))
        end
    end)

    it("rounds identity properly (55 / 100 and 55%, #real)",
    function()
        local config = require 'npge.config'
        local revert = config:updateKeys({
            general = {
                MIN_LENGTH = 100,
                FRAME_LENGTH = 100,
                MIN_END = 3,
                MIN_IDENTITY = 0.55,
            },
        })
        --
        local t1 = [[
ATCTCGTTTATCTGTGAGATGTTCTTGTCGAGTTGGCTCAACTTGCGCTGCTATTG
TTGTGTCCTCTCCATTGGCCCGGATTCGTT---------GACTAGGCATTTGGTAT
CGTCCAGTATAGATCTGCCGCGTAGCTTTTTGAGAAAAGGCGTAG--------CGG
GACCAAGCTTTTT-----------------------GGTTGGGGTTTTCCAACATG
CT]]
        local t2 = [[
ATCTCGTTTATCTGTGAGATGTTCTTGTCGAGTTGGCTCAACTTGCGCTGCTATTG
TTGTGTCCTCTCCATTGGCCCGGATTCGTT---------GACTAGGCATTTGGTAT
CGTCCAGTATAGATCTGCCGCGTAGCTTTTTGAGAAAAGGCGTAG--------CGG
GACCAAGCTTTTT-----------------------GGTTGGGGTTTTCCAACATG
CT]]
        local t3 = [[
ATCTCATCTATCTGTGAGACGTCCTTGTCGAGTTGGCCCAATTTTCGCA-----TG
TGGTGAATT-TCTACCGGTCCGGAGTATTTAATGTTATTGACTGGGCATTTGTTAT
CGTCCAGTATAGATCTGCTGCTTAGCATTTCAAAAAGAGGCGTGGTCTGTAGGCGG
GACCAAGCTTTTTTTGAAGTCCCACAAGTTGAGTGCGGTTAGGAGTTTCCTCAATG
CT]]
        local m = require 'npge.model'
        local s1 = m.Sequence('s1', t1)
        local s2 = m.Sequence('s2', t2)
        local s3 = m.Sequence('s3', t3)
        local block = m.Block {
            {m.Fragment(s1, 0, s1:length() - 1, 1), t1},
            {m.Fragment(s2, 0, s2:length() - 1, 1), t2},
            {m.Fragment(s3, 0, s3:length() - 1, 1), t3},
        }
        local isGood = require 'npge.block.isGood'
        assert.truthy(isGood(block))
        --
        revert()
    end)

    it("works if FRAME_LENGTH != MIN_LENGTH", function()
        local isGood = require 'npge.block.isGood'
        local config = require 'npge.config'
        --
        local t1 = "TATATTTTTTTTTTTTT"
        local t2 = "TTTTTTTTTTTTTTTTT"
        local Sequence = require 'npge.model.Sequence'
        local s1 = Sequence('s1', t1)
        local s2 = Sequence('s2', t2)
        local Fragment = require 'npge.model.Fragment'
        local f1 = Fragment(s1, 0, s1:length() - 1, 1)
        local f2 = Fragment(s2, 0, s2:length() - 1, 1)
        local Block = require 'npge.model.Block'
        local block = Block({f1, f2})
        --
        local revert = config:updateKeys({general = {
            MIN_LENGTH = 3,
            FRAME_LENGTH = 2,
            MIN_IDENTITY = 0.5,
            MIN_END = 1,
        }})
        assert.truthy(isGood(block))
        revert()
        --
        local revert = config:updateKeys({general = {
            MIN_LENGTH = 3,
            FRAME_LENGTH = 2,
            MIN_IDENTITY = 0.5,
            MIN_END = 3,
        }})
        assert.truthy(isGood(block))
        revert()
        --
        local revert = config:updateKeys({general = {
            MIN_LENGTH = 3,
            FRAME_LENGTH = 3,
            MIN_IDENTITY = 0.5,
            MIN_END = 1,
        }})
        assert.falsy(isGood(block))
        revert()
        --
        local revert = config:updateKeys({general = {
            MIN_LENGTH = 2,
            FRAME_LENGTH = 3,
            MIN_IDENTITY = 0.5,
            MIN_END = 1,
        }})
        assert.falsy(isGood(block))
        revert()
        --
        local revert = config:updateKeys({general = {
            MIN_LENGTH = 100,
            FRAME_LENGTH = 2,
            MIN_IDENTITY = 0.5,
            MIN_END = 1,
        }})
        assert.falsy(isGood(block))
        revert()
        --
        local revert = config:updateKeys({general = {
            MIN_LENGTH = 3,
            FRAME_LENGTH = 100,
            MIN_IDENTITY = 0.5,
            MIN_END = 1,
        }})
        assert.truthy(isGood(block))
        revert()
    end)

    it("works if FRAME_LENGTH != MIN_LENGTH (real example)",
    function()
        local isGood = require 'npge.block.isGood'
        local config = require 'npge.config'
        --
        local rows = {
    'AGTAAGTCAATAGGGAAATCGACCGAGCCAGGTACTGAAGGGCGGCAGTCATGA',
    'AGTAAGTCAATAGGGAAATCGACCGAGCCAGGTACTGAAGGGCGGCAGTCATGA',
    'AGTAAGTGGGGAAGGAAAGCAACCAAGCCAGGTACTGAAGGGCGGCAGTCATGA',
    'AGTAAGTAAATAAGGAAATCGACCAAGCCAGGTACTGAAGGGCGGCAGTCATGA',
    'AGTAAGTCAATAGGGAAATCGACCGAGCCAGGTACTGAAGGGCGGCAGTCATGA',
    'AGTAAGTGGATAGGGAAATCGAATAAGCCAGGTACTGAAGGGCGGCAGTCATGA',
    'AGTAAGTGAGAAGGGAAAGCAAGCGAACCAGATACTGAAGAGCGGCAGTCATGA',
    'AGTAAGTCAATAGGGAAATCGACCGAGCCAGGTACTGAAGGGCGGCAGTCATGA',
    'AGTAAGTGGATAGGGAAATTGACTAAGCCAGGTACTGAAGGGTGGCAGTCATGA',
    'AGTAAGTGGATAGGGAAATCGACTAAGCCAGGTACTGAAGGGTGGCAGTCATGA',
    'AGTAAGTGGATAGGGAAATCGACTAAGCCAGGTACTGAAGGGTGGCAGTCATGA',
    'AGTGGATAGGGAAATCGACCAAGCCAGGTACGCACTGAAGGGCGGCAGTCATGA',
    'AGTAAGTCAATAGGGAAATCGACCGAGCCAGGTACTGAAGGGCGGCAGTCATGA',
    'AGTAAGTAAATAGGGAAATCGACCAAGCCAGGTACTGAAGGGCGGCAGTCATGA',
    'AGTAAGTAAATAGGGAAATCGACCAAGCCAGGTACTGAAGGGCGGCAGTCATGA',
    'AGTAAGTAAATAGGGAAATCGACCAAGCCAGGTACTGAAGGGCGGCAGTCATGA',
    'AGTGGATAGGGAAATCGACCAAGCTAGGTACGCACTGAAGGGCGGCAGTCATGA',
    'AGTAAGTCAATGGGGAAATCGACCGAGCCGGGTACTGAAGAGCGGCAGTCATGA',
    'AGTAAGTGGATAGGGAAATCGACTAAGCCAGGTACTGAAGGGTGGCAGTCATGA',
    'AGTAAGTGGATAGGGAAATCGAATAAGCCAGGTACTGAAGGGCGGCAGTCATGA',
    'AGTAAGTGGATAGGGAAATCGACTAAGCCAGGTACTGAAGGGTGGCAGTCATGA',
    'AGTAAGTGAGAAGGGAGACCAACTAAGCTAAGTACTGAAGGGCGGCAGTCATGA',
    'AGTAAGTGGGGAGGGAAACCAACCAAGCCAGGTACTGAAGGGCGGCAGTCATGA',
    'AGTAAGTAAATAGGGAAATCGACCAAGCCAGGTACTGAAGGGCGGCAGTCATGA',
        }
        local model = require 'npge.model'
        local algo = require 'npge.algo'
        local seqs = {}
        for i, row in ipairs(rows) do
            local seq = model.Sequence('s' .. i, row)
            table.insert(seqs, seq)
        end
        local bs = model.BlockSet(seqs, {})
        bs = algo.Cover(bs)
        local block = bs:blocks()[1]
        --
        local revert = config:updateKeys({general = {
            MIN_LENGTH = 50,
            FRAME_LENGTH = 200,
            MIN_IDENTITY = 0.50,
            MIN_END = 3,
        }})
        assert.falsy(isGood(block))
        revert()
    end)
end)
