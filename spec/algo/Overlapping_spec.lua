-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2016 Boris Nagaev
-- See the LICENSE file for terms of use.

describe("npge.algo.Overlapping", function()
    it("get list of blocks overlapping with a block",
    function()
        local model = require 'npge.model'
        local text = ("A"):rep(1000)
        local seq = model.Sequence("seq", text)
        local b1 = model.Block({
            model.Fragment(seq, 10, 11, 1),
            model.Fragment(seq, 30, 31, 1),
        })
        local b2 = model.Block({
            model.Fragment(seq, 20, 21, 1),
        })
        local bs = model.BlockSet({seq}, {b1, b2})
        local Overlapping = require 'npge.algo.Overlapping'
        assert.same(Overlapping(bs, b1), {b1})
        assert.same(Overlapping(bs, b2), {b2})
        assert.same(Overlapping(bs, model.Block({
            model.Fragment(seq, 20, 20, 1),
        })), {b2})
        assert.same(Overlapping(bs, model.Block({
            model.Fragment(seq, 5, 15, 1),
        })), {b1})
        --
        local both = Overlapping(bs, model.Block({
            model.Fragment(seq, 0, 100, 1),
        }))
        local both_e = {b1, b2}
        table.sort(both)
        table.sort(both_e)
        assert.same(both, both_e)
    end)
end)
