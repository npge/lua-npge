-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

describe("npge.io.ReadFromBs", function()
    it("reads blockset from .bs format #old_bs", function()
        -- prepare sequences
        local Sequence = require 'npge.model.Sequence'
        local s1 = Sequence('name', 'ATGC', 'description')
        local s2 = Sequence('seq1', 'ATGC')
        local s3 = Sequence('seq2', 'ATGCATGCATGC', 'bla bla')
        local BlockSet = require 'npge.model.BlockSet'
        local bs1 = BlockSet({s1, s2, s3}, {})
        -- parse .bs file
        local ReadFromBs = require 'npge.io.ReadFromBs'
        local bs_text =
[[
>name_0_1 block=b1
AT
>seq1_0_1 block=b1
AT
>seq2_5_4 block=b1
AT

>name_0_0 block=b2
A
>seq1_1_-1 block=b2
A
>seq2_5_-1 block=b2
A

>name_1_0 block=b3
AT-
>seq1_1_0 block=b3
A-T
>seq2_4_5 block=b3
AT-
]]
        local bs2 = ReadFromBs(bs_text, bs1)
        --
        local Block = require 'npge.model.Block'
        local Fragment = require 'npge.model.Fragment'
        local b1 = Block({
            Fragment(s1, 0, 1, 1),
            Fragment(s2, 0, 1, 1),
            Fragment(s3, 5, 4, -1),
        })
        local b2 = Block({
            Fragment(s1, 0, 0, 1),
            Fragment(s2, 1, 1, -1),
            Fragment(s3, 5, 5, -1),
        })
        local b3 = Block({
            {Fragment(s1, 1, 0, -1), 'AT-'},
            {Fragment(s2, 1, 0, -1), 'A-T'},
            {Fragment(s3, 4, 5, 1), 'AT-'},
        })
        local bs3 = BlockSet({s1, s2, s3}, {
            b1,
            b2,
            b3,
        })
        assert.equal(bs2, bs3)
        assert.equal(bs2:blockByName("b1"), b1)
        assert.equal(bs2:blockByName("b2"), b2)
        assert.equal(bs2:blockByName("b3"), b3)
    end)

    it("reads blockset from #old_bs format without reference",
    function()
        -- parse .bs file
        local ReadFromBs = require 'npge.io.ReadFromBs'
        local bs_text =
[[
>foo_0_1 block=b1
AT
>foo_2_3 block=b1
AT
]]
        local bs_seen = ReadFromBs(bs_text)
        --
        local model = require 'npge.model'
        local seq_exp = model.Sequence("foo", "ATAT")
        local bs_exp = model.BlockSet({seq_exp}, {
            model.Block({
                model.Fragment(seq_exp, 0, 1, 1),
                model.Fragment(seq_exp, 2, 3, 1),
            }),
        })
        assert.equal(bs_seen, bs_exp)
    end)

    it("reads blockset from #new_bs format without reference",
    function()
        -- parse .bs file
        local ReadFromBs = require 'npge.io.ReadFromBs'
        local bs_text =
[[
>g&c&c_3_0_1 block=b1
TA-
>g&c&c_1_2_1 block=b1
T-A
]]
        local bs_seen = ReadFromBs(bs_text)
        --
        local model = require 'npge.model'
        local seq_exp = model.Sequence("g&c&c", "ATAT")
        local bs_exp = model.BlockSet({seq_exp}, {
            model.Block({
                {model.Fragment(seq_exp, 3, 0, 1), "TA-"},
                {model.Fragment(seq_exp, 1, 2, 1), "T-A"},
            }),
        })
        assert.equal(bs_seen, bs_exp)
    end)

    it("reads blockset from #new_bs format without reference ori=-1",
    function()
        -- parse .bs file
        local ReadFromBs = require 'npge.io.ReadFromBs'
        local bs_text =
[[
>g&c&c_0_3_-1 block=b1
TA-
>g&c&c_1_2_1 block=b1
T-A
]]
        local bs_seen = ReadFromBs(bs_text)
        --
        local model = require 'npge.model'
        local seq_exp = model.Sequence("g&c&c", "ATAT")
        local bs_exp = model.BlockSet({seq_exp}, {
            model.Block({
                {model.Fragment(seq_exp, 0, 3, -1), "TA-"},
                {model.Fragment(seq_exp, 1, 2, 1), "T-A"},
            }),
        })
        assert.equal(bs_seen, bs_exp)
    end)

    it("throws if non-partition is read without a reference",
    function()
        -- parse .bs file
        local ReadFromBs = require 'npge.io.ReadFromBs'
        local bs_text =
[[
>g&c&c_3_0_1 block=b1
TA-
>g&c&c_1_1_1 block=b1
T--
]]
        assert.has_error(function()
            ReadFromBs(bs_text)
        end)
    end)

end)
