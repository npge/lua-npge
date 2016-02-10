-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2016 Boris Nagaev
-- See the LICENSE file for terms of use.

describe("npge.block.info", function()
    it("returns info about block", function()
        local info = require 'npge.block.info'
        local model = require 'npge.model'
        local s1 = model.Sequence('s1', 'AAAA')
        local s2 = model.Sequence('s2', 'CCCC')
        local f1 = model.Fragment(s1, 0, 3, 1)
        local f2 = model.Fragment(s2, 0, 3, 1)
        local b = model.Block({f1, f2})
        assert.same(info(b), {
            size = 2,
            length = 4,
            identity = 0.0,
            gc = 0.5,
        })
    end)

    it("returns info about block with genomes", function()
        local info = require 'npge.block.info'
        local model = require 'npge.model'
        local s1 = model.Sequence('g1&c&c', 'AAAA')
        local s2 = model.Sequence('g2&c&c', 'CCCC')
        local f1 = model.Fragment(s1, 0, 3, 1)
        local f2 = model.Fragment(s2, 0, 3, 1)
        local b = model.Block({f1, f2})
        assert.same(info(b), {
            size = 2,
            length = 4,
            identity = 0.0,
            gc = 0.5,
            genomes = {
                g1 = 1,
                g2 = 1,
            },
        })
    end)
end)
