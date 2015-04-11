-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

describe("npge.algo.ReadFromBs", function()
    it("reads blockset from .bs format #old_bs", function()
        -- prepare sequences
        local Sequence = require 'npge.model.Sequence'
        local s1 = Sequence('name', 'ATGC', 'description')
        local s2 = Sequence('seq1', 'ATGC')
        local s3 = Sequence('seq2', 'ATGCATGCATGC', 'bla bla')
        local BlockSet = require 'npge.model.BlockSet'
        local bs1 = BlockSet({s1, s2, s3}, {})
        -- parse .bs file
        local ReadFromBs = require 'npge.algo.ReadFromBs'
        local it_from_array =
            require 'npge.util.it_from_array'
        local split = require 'npge.util.split'
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
        local lines = split(bs_text, '\n')
        local it = it_from_array(lines)
        local bs2 = ReadFromBs(it, bs1)
        --
        local Block = require 'npge.model.Block'
        local Fragment = require 'npge.model.Fragment'
        local bs3 = BlockSet({s1, s2, s3}, {
            Block({
                Fragment(s1, 0, 1, 1),
                Fragment(s2, 0, 1, 1),
                Fragment(s3, 5, 4, -1),
            }),
            Block({
                Fragment(s1, 0, 0, 1),
                Fragment(s2, 1, 1, -1),
                Fragment(s3, 5, 5, -1),
            }),
            Block({
                {Fragment(s1, 1, 0, -1), 'AT-'},
                {Fragment(s2, 1, 0, -1), 'A-T'},
                {Fragment(s3, 4, 5, 1), 'AT-'},
            }),
        })
        assert.equal(bs2, bs3)
    end)
end)
