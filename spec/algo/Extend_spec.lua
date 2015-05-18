-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

describe("npge.algo.Extend", function()
    it("extend fragment to left and to right",
    function()
        local model = require 'npge.model'
        local s = model.Sequence("seq", "ATGC")
        local f = model.Fragment(s, 1, 1, 1)
        local bs = model.BlockSet({s}, {model.Block({f})})
        local Extend = require 'npge.algo.Extend'
        local bs2 = Extend(bs, 1)
        assert.equal(bs2, model.BlockSet({s}, {model.Block({
            model.Fragment(s, 0, 2, 1),
        })}))
    end)

    it("extends MIN_LENGTH positions by default", function()
        local model = require 'npge.model'
        local s = model.Sequence("seq", ("A"):rep(10000))
        local f = model.Fragment(s, 5000, 5000, 1) -- middle
        local bs = model.BlockSet({s}, {model.Block({f})})
        local Extend = require 'npge.algo.Extend'
        local bs2 = Extend(bs)
        local e = require 'npge.config'.general.MIN_LENGTH
        assert.equal(bs2, model.BlockSet({s}, {model.Block({
            model.Fragment(s, 5000 - e, 5000 + e, 1),
        })}))
    end)
end)
