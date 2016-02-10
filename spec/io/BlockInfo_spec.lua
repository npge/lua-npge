-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2016 Boris Nagaev
-- See the LICENSE file for terms of use.

describe("npge.io.BlockInfo", function()
    it("returns iterator returning block infos", function()
        local model = require 'npge.model'
        local s1 = model.Sequence('s1', 'AAAA')
        local s2 = model.Sequence('s2', 'CCCC')
        local f1 = model.Fragment(s1, 0, 3, 1)
        local f2 = model.Fragment(s2, 0, 3, 1)
        local b = model.Block({f1, f2})
        local bs = model.BlockSet({s1, s2}, {b})
        local BlockInfo = require 'npge.io.BlockInfo'
        local no_genomes = true
        local it = BlockInfo(bs, no_genomes)
        local line1 = it()
        local line2 = it()
        local line3 = it()
        assert.truthy(line2:match('2')) -- size
        assert.truthy(line2:match('4')) -- length
        assert.truthy(line2:match('0.5')) -- gc
        assert.falsy(line3)
    end)

    it("prints genomes counts in blocks", function()
        local model = require 'npge.model'
        local s1 = model.Sequence('g1&c&c', 'AAAA')
        local s2 = model.Sequence('g2&c&c', 'CCCC')
        local f1 = model.Fragment(s1, 0, 3, 1)
        local f2 = model.Fragment(s2, 0, 3, 1)
        local b = model.Block({f1, f2})
        local bs = model.BlockSet({s1, s2}, {b})
        local BlockInfo = require 'npge.io.BlockInfo'
        local it = BlockInfo(bs)
        local line1 = it()
        local line2 = it()
        local line3 = it()
        assert.truthy(line1:match('g1'))
        assert.truthy(line1:match('g2'))
        assert.truthy(line2:match('1')) -- count
        assert.falsy(line3)
    end)
end)
