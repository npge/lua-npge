-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2016 Boris Nagaev
-- See the LICENSE file for terms of use.

describe("npge.block.unwind", function()
    it("unwinds block from consensus to original sequences",
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
        --
        local unwind = require 'npge.block.unwind'
        local unwound = unwind(cons_b, {['']=bs})
        local unwound_exp = model.Block({
            {model.Fragment(s, 0, 0, 1), 'A'},
            {model.Fragment(s, 4, 4, -1), 'A'},
            {model.Fragment(s, 2, 2, -1), 'A'},
            {model.Fragment(s, 3, 3, 1), 'A'},
        })
        assert.are.equal(unwound, unwound_exp)
    end)

    it("unwinds block from consensus (less fragments)",
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
        --
        local unwind = require 'npge.block.unwind'
        local unwound = unwind(cons_b, {['']=bs})
        local unwound_exp = model.Block({
            {model.Fragment(s, 1, 1, 1), 'A'},
        })
        assert.are.equal(unwound, unwound_exp)
    end)

    it("unwinds block from consensus (no fragments)",
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
        --
        local unwind = require 'npge.block.unwind'
        local unwound = unwind(cons_b, {['']=bs})
        assert.are.equal(unwound, nil)
    end)

    it("unwinds blocks from consensus (reversed on consensus)",
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
        --
        local unwind = require 'npge.block.unwind'
        local unwound = unwind(cons_b, {['']=bs})
        local unwound_exp = model.Block({
            {model.Fragment(s1, 2, 4, 1), 'TAT'},
            {model.Fragment(s2, 0, 3, -1), 'TAT'},
            {model.Fragment(s1, 3, 2, -1), 'TA-'},
            {model.Fragment(s2, 4, 0, 1), 'TA-'},
        })
        assert.are.equal(unwound, unwound_exp)
    end)

    it("unwinds blocks from consensus (gaps, gaps, gaps)",
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
        --
        local unwind = require 'npge.block.unwind'
        local unwound = unwind(cons_b, {['']=bs})
        local unwound_exp = model.Block({
            {model.Fragment(s, 2, 4, 1), 'TAT'},
            {model.Fragment(s, 1, 0, -1), 'T-T'},
            {model.Fragment(s, 3, 2, -1), 'TA-'},
            {model.Fragment(s, 1, 1, 1), '-A-'},
        })
        assert.are.equal(unwound, unwound_exp)
    end)

    it("unwinds blocks from consensus (parted unique)",
    function()
        local model = require 'npge.model'
        local s = model.Sequence("g&c&c", "AATAT")
        local block = model.Block({
            model.Fragment(s, 0, 4, 1),
        })
        local bs = model.BlockSet({s}, {block})
        --
        local CS = require 'npge.algo.ConsensusSequences'
        local cs = CS(bs)
        assert(#cs:sequences() == 1)
        local cons_seq = cs:sequences()[1]
        if cons_seq == s then
            local cons_b = model.Block({
                model.Fragment(cons_seq, 4, 0, 1),
            })
            --
            local unwind = require 'npge.block.unwind'
            local unwound = unwind(cons_b, {['']=bs})
            local unwound_exp = cons_b
            assert.are.equal(unwound, unwound_exp)
        end
    end)
end)
