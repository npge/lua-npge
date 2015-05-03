-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

describe("npge.block.hitName", function()
    it("gets type of block", function()
        local model = require 'npge.model'
        local text = ("A"):rep(1000)
        local g1c1 = model.Sequence("g1&c1&c", text)
        local g2c1 = model.Sequence("g2&c1&c", text)
        local hit = model.Block({
            model.Fragment(g1c1, 1, 100, 1),
            model.Fragment(g2c1, 1, 100, 1),
        })
        local hitName = require 'npge.block.hitName'
        assert.truthy(hitName(hit))
    end)
end)
