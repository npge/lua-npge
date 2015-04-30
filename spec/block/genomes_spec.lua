-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

describe("npge.block.genomes", function()
    it("get list of genomes from block", function()
        local model = require 'npge.model'
        local g1c1 = model.Sequence("g1&c1&c", "ATGC")
        local g1c2 = model.Sequence("g1&c2&c", "ATGC")
        local g2c1 = model.Sequence("g2&c1&c", "ATGC")
        local F = model.Fragment
        local B = model.Block
        local genomes = require 'npge.block.genomes'
        local g = genomes(B({
            F(g1c1, 1, 1, 1),
            F(g1c2, 1, 1, 1),
            F(g2c1, 1, 1, 1),
        }))
        table.sort(g)
        assert.same(g, {"g1", "g2"})
    end)

    it("throws if genomes are unknown", function()
        assert.has_error(function()
            local model = require 'npge.model'
            local g1c1 = model.Sequence("g1c1c", "ATGC")
            local g1c2 = model.Sequence("g1c2c", "ATGC")
            local g2c1 = model.Sequence("g2c1c", "ATGC")
            local F = model.Fragment
            local B = model.Block
            local genomes = require 'npge.block.genomes'
            genomes(B({
                F(g1c1, 1, 1, 1),
            }))
        end)
    end)
end)
