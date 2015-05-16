-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

describe("npge.algo.Subtract", function()
    it("subtract one blockset from another", function()
        local model = require 'npge.model'
        local s = model.Sequence("s", "ATAT")
        local f1 = model.Fragment(s, 0, 0, 1)
        local f2 = model.Fragment(s, 1, 1, 1)
        local b1 = model.Block({f1})
        local b2 = model.Block({f2})
        local bs1 = model.BlockSet({s}, {b1, b2})
        local bs2 = model.BlockSet({s}, {b2})
        local Subtract = require 'npge.algo.Subtract'
        local difference = Subtract(bs1, bs2)
        assert.equal(difference, model.BlockSet({s}, {b1}))
    end)
end)
