-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

describe("npge.algo.JoinMinor", function()

    local revert

    before_each(function()
        local config = require 'npge.config'
        revert = config:updateKeys({
            general = {
                MIN_LENGTH = 100,
                FRAME_LENGTH = 100,
                MIN_IDENTITY = 0.9,
                MIN_END = 3,
            },
        })
    end)

    after_each(function()
        revert()
    end)

    it("return joined minor blocks", function()
        local model = require 'npge.model'
        local algo = require 'npge.algo'
        local g1 = model.Sequence("g1&c&c", ("A"):rep(1000))
        local g2 = model.Sequence("g2&c&c", ("A"):rep(1000))
        local block1 = model.Block({
            model.Fragment(g1, 10, 500, 1),
            model.Fragment(g2, 10, 500, 1),
        })
        local block2 = model.Block({
            model.Fragment(g1, 510, 990, 1),
            model.Fragment(g2, 510, 990, 1),
        })
        local bs = model.BlockSet({g1, g2}, {block1, block2})
        bs = algo.Cover(bs)
        local minor = algo.JoinMinor(bs)
        assert.equal(minor, model.BlockSet({g1, g2}, {
            model.Block({
                model.Fragment(g1, 501, 509, 1),
                model.Fragment(g2, 501, 509, 1),
            }),
            model.Block({
                model.Fragment(g1, 991, 9, 1),
                model.Fragment(g2, 991, 9, 1),
            }),
        }))
    end)
end)
