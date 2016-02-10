-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2016 Boris Nagaev
-- See the LICENSE file for terms of use.

describe("npge.algo.AlignLeft", function()
    it("align blocks of blockset to left", function()
        local model = require 'npge.model'
        local s1 = model.Sequence('s1', "ATG")
        local s2 = model.Sequence('s2', "A-G")
        local f1 = model.Fragment(s1, 0, s1:length() - 1, 1)
        local f2 = model.Fragment(s2, 0, s2:length() - 1, 1)
        local block = model.Block({
            {f1, 'ATG'},
            {f2, 'A-G'},
        })
        local bs = model.BlockSet({s1, s2}, {block})
        --
        local AlignLeft = require 'npge.algo.AlignLeft'
        local bs_aligned = AlignLeft(bs)
        assert.equal(bs_aligned, model.BlockSet({s1, s2}, {
            model.Block({f1, f2}),
        }))
    end)
end)
