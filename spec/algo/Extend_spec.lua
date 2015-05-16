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
        local bs2 = Extend(bs, function(block)
            assert(block:type() == 'Block')
            return 1, 2
        end)
        assert.equal(bs2, model.BlockSet({s}, {model.Block({
            model.Fragment(s, 0, 3, 1),
        })}))
    end)

    it("single length = left = right",
    function()
        local model = require 'npge.model'
        local s = model.Sequence("seq", "ATGC")
        local f = model.Fragment(s, 1, 1, 1)
        local bs = model.BlockSet({s}, {model.Block({f})})
        local Extend = require 'npge.algo.Extend'
        local bs2 = Extend(bs, function(block)
            assert(block:type() == 'Block')
            return 1
        end)
        assert.equal(bs2, model.BlockSet({s}, {model.Block({
            model.Fragment(s, 0, 2, 1),
        })}))
    end)
end)
