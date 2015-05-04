-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

describe("npge.algo.UnwindBlocks", function()
    it("unwinds blockset from consensus to original sequences",
    function()
        local model = require 'npge.model'
        local s = model.Sequence("g&c&c", "AATAT")
        local f1 = model.Fragment(s, 0, 2, 1) -- AAT
        local f2 = model.Fragment(s, 4, 3, -1) -- AT
        local block = model.Block({
            {f1, 'AAT'},
            {f2, 'A-T'},
        })
        local bs = model.BlockSet({s}, {block})
        --
        local CS = require 'npge.algo.ConsensusSequences'
        local cs = CS(bs)
        assert(#cs:sequences() == 1)
        local cons_seq = cs:sequences()[1]
        local cons_f1 = model.Fragment(cons_seq, 0, 0, 1)
        local cons_f2 = model.Fragment(cons_seq, 2, 2, -1)
        local cons_b = model.Block({cons_f1, cons_f2})
        local cons_bs = model.BlockSet({cons_seq}, {cons_b})
        --
        local UnwindBlocks = require 'npge.algo.UnwindBlocks'
        local unwound = UnwindBlocks(cons_bs, {['']=bs})
        local unwound_exp = model.BlockSet({s}, {model.Block({
            {model.Fragment(s, 0, 0, 1), 'A'},
            {model.Fragment(s, 4, 4, -1), 'A'},
            {model.Fragment(s, 2, 2, -1), 'A'},
            {model.Fragment(s, 3, 3, 1), 'A'},
        })})
        assert.are.equal(unwound, unwound_exp)
    end)

    it("unwinds blockset from consensus (less fragments)",
    function()
        local model = require 'npge.model'
        local s = model.Sequence("g&c&c", "AATAT")
        local f1 = model.Fragment(s, 0, 2, 1) -- AAT
        local f2 = model.Fragment(s, 4, 3, -1) -- AT
        local block = model.Block({
            {f1, 'AAT'},
            {f2, 'A-T'},
        })
        local bs = model.BlockSet({s}, {block})
        --
        local CS = require 'npge.algo.ConsensusSequences'
        local cs = CS(bs)
        assert(#cs:sequences() == 1)
        local cons_seq = cs:sequences()[1]
        local cons_f1 = model.Fragment(cons_seq, 1, 1, 1)
        local cons_b = model.Block({cons_f1})
        local cons_bs = model.BlockSet({cons_seq}, {cons_b})
        --
        local UnwindBlocks = require 'npge.algo.UnwindBlocks'
        local unwound = UnwindBlocks(cons_bs, {['']=bs})
        local unwound_exp = model.BlockSet({s}, {model.Block({
            {model.Fragment(s, 1, 1, 1), 'A'},
        })})
        assert.are.equal(unwound, unwound_exp)
    end)

    it("unwinds blockset from consensus (no fragments)",
    function()
        local model = require 'npge.model'
        local s = model.Sequence("g&c&c", "AATAT")
        local f1 = model.Fragment(s, 0, 2, 1) -- AAT
        local f2 = model.Fragment(s, 4, 3, -1) -- AT
        local block = model.Block({
            {f2, 'A-T'},
        })
        local bs = model.BlockSet({s}, {block})
        --
        local CS = require 'npge.algo.ConsensusSequences'
        local cs = CS(bs)
        assert(#cs:sequences() == 1)
        local cons_seq = cs:sequences()[1]
        local cons_f1 = model.Fragment(cons_seq, 1, 1, 1)
        local cons_b = model.Block({cons_f1})
        local cons_bs = model.BlockSet({cons_seq}, {cons_b})
        --
        local UnwindBlocks = require 'npge.algo.UnwindBlocks'
        local unwound = UnwindBlocks(cons_bs, {['']=bs})
        local unwound_exp = model.BlockSet({s}, {})
        assert.are.equal(unwound, unwound_exp)
    end)

    it("unwinds blockset from consensus to original sequences",
    function()
        local model = require 'npge.model'
        local s1 = model.Sequence("g1&c&c", "AATAT")
        local s2 = model.Sequence("g2&c&c", "AATAT")
        local block = model.Block({
            {model.Fragment(s1, 2, 4, 1), 'TAT'},
            {model.Fragment(s2, 0, 3, -1), 'TAT'},
        })
        local bs = model.BlockSet({s1, s2}, {block})
        --
        local CS = require 'npge.algo.ConsensusSequences'
        local cs = CS(bs)
        assert(#cs:sequences() == 1)
        local cons_seq = cs:sequences()[1]
        local cons_b = model.Block({
            {model.Fragment(cons_seq, 0, 2, 1), 'TAT'},
            {model.Fragment(cons_seq, 1, 0, -1), 'TA-'},
        })
        local cons_bs = model.BlockSet({cons_seq}, {cons_b})
        --
        local UnwindBlocks = require 'npge.algo.UnwindBlocks'
        local unwound = UnwindBlocks(cons_bs, {['']=bs})
        local unwound_exp = model.BlockSet({s1, s2},
            {model.Block({
                {model.Fragment(s1, 2, 4, 1), 'TAT'},
                {model.Fragment(s2, 0, 3, -1), 'TAT'},
                {model.Fragment(s1, 3, 2, -1), 'TA-'},
                {model.Fragment(s2, 4, 0, 1), 'TA-'},
        })})
        assert.are.equal(unwound, unwound_exp)
    end)

    it("unwinds blockset (multiple original blocksets)",
    function()
        local model = require 'npge.model'
        local s1 = model.Sequence("g1&c&c", "AATAT")
        local s2 = model.Sequence("g2&c&c", "AATAT")
        local b1 = model.Block({
            {model.Fragment(s1, 2, 4, 1), 'TAT'},
        })
        local b2 = model.Block({
            {model.Fragment(s2, 0, 3, -1), 'TAT'},
        })
        local bs1 = model.BlockSet({s1}, {b=b1})
        local bs2 = model.BlockSet({s2}, {b=b2})
        --
        local CS = require 'npge.algo.ConsensusSequences'
        local Merge = require 'npge.algo.Merge'
        local cs = Merge {CS(bs1, "bs1-"), CS(bs2, "bs2-")}
        assert.equal(#cs:sequences(), 2)
        local cons_seq1 = cs:sequenceByName("bs1-b")
        local cons_seq2 = cs:sequenceByName("bs2-b")
        assert.truthy(cons_seq1)
        assert.truthy(cons_seq2)
        local cons_b = model.Block({
            {model.Fragment(cons_seq1, 0, 2, 1), 'TAT'},
            {model.Fragment(cons_seq2, 1, 0, -1), 'TA-'},
        })
        local cons_bs = model.BlockSet({cons_seq1, cons_seq2},
            {cons_b})
        --
        local UnwindBlocks = require 'npge.algo.UnwindBlocks'
        local unwound = UnwindBlocks(cons_bs,
            {['bs1-']=bs1, ['bs2-']=bs2})
        local unwound_exp = model.BlockSet({s1, s2},
            {model.Block({
                {model.Fragment(s1, 2, 4, 1), 'TAT'},
                {model.Fragment(s2, 4, 0, 1), 'TA-'},
        })})
        assert.are.equal(unwound, unwound_exp)
    end)

    it("keeps names of blocks", function()
        local model = require 'npge.model'
        local s1 = model.Sequence("g1&c&c", "AATAT")
        local b1 = model.Block({
            {model.Fragment(s1, 2, 4, 1), 'TAT'},
        })
        local bs1 = model.BlockSet({s1}, {b=b1})
        --
        local CS = require 'npge.algo.ConsensusSequences'
        local cs = CS(bs1, "bs1-")
        assert.equal(#cs:sequences(), 1)
        local cons_seq1 = cs:sequenceByName("bs1-b")
        local cons_b = model.Block({
            {model.Fragment(cons_seq1, 0, 2, 1), 'TAT'},
        })
        local cons_bs = model.BlockSet({cons_seq1},
            {cons_b = cons_b})
        --
        local UnwindBlocks = require 'npge.algo.UnwindBlocks'
        local unwound = UnwindBlocks(cons_bs, {['bs1-']=bs1})
        assert.equal(unwound:nameByBlock(model.Block({
            {model.Fragment(s1, 2, 4, 1), 'TAT'},
        })), "cons_b")
    end)

    it("unwinds blockset from consensus (gaps, gaps, gaps)",
    function()
        local model = require 'npge.model'
        local s = model.Sequence("g&c&c", "AATAT")
        local block = model.Block({
            {model.Fragment(s, 2, 4, 1), 'TAT'},
            {model.Fragment(s, 1, 0, -1), 'T-T'},
        })
        local bs = model.BlockSet({s}, {block})
        --
        local CS = require 'npge.algo.ConsensusSequences'
        local cs = CS(bs)
        assert(#cs:sequences() == 1)
        local cons_seq = cs:sequences()[1]
        local cons_b = model.Block({
            {model.Fragment(cons_seq, 0, 2, 1), 'TAT'},
            {model.Fragment(cons_seq, 1, 0, -1), 'TA-'},
        })
        local cons_bs = model.BlockSet({cons_seq}, {cons_b})
        --
        local UnwindBlocks = require 'npge.algo.UnwindBlocks'
        local unwound = UnwindBlocks(cons_bs, {['']=bs})
        local unwound_exp = model.BlockSet({s}, {model.Block({
            {model.Fragment(s, 2, 4, 1), 'TAT'},
            {model.Fragment(s, 1, 0, -1), 'T-T'},
            {model.Fragment(s, 3, 2, -1), 'TA-'},
            {model.Fragment(s, 1, 1, 1), '-A-'},
        })})
        assert.are.equal(unwound, unwound_exp)
    end)
end)
