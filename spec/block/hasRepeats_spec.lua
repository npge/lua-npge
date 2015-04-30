-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

describe("npge.block.hasRepeats", function()
    it("detects block with fragments in same genome", function()
        local model = require 'npge.model'
        local g1c1 = model.Sequence("g1&c1&c", "ATGC")
        local g1c2 = model.Sequence("g1&c2&c", "ATGC")
        local g2c1 = model.Sequence("g2&c1&c", "ATGC")
        local F = model.Fragment
        local B = model.Block
        local hasRepeats = require 'npge.block.hasRepeats'
        assert.falsy(hasRepeats(B({
            F(g1c1, 1, 1, 1),
        })))
        assert.falsy(hasRepeats(B({
            F(g1c1, 1, 1, 1),
            F(g2c1, 1, 1, 1),
        })))
        assert.truthy(hasRepeats(B({
            F(g1c1, 1, 1, 1),
            F(g1c2, 1, 1, 1),
        })))
        assert.truthy(hasRepeats(B({
            F(g1c1, 1, 1, 1),
            F(g1c2, 1, 1, 1),
            F(g2c1, 1, 1, 1),
        })))
    end)

    it("throws if genomes are unknown", function()
        assert.has_error(function()
            local model = require 'npge.model'
            local g1c1 = model.Sequence("g1c1c", "ATGC")
            local g1c2 = model.Sequence("g1c2c", "ATGC")
            local g2c1 = model.Sequence("g2c1c", "ATGC")
            local F = model.Fragment
            local B = model.Block
            local hasRepeats = require 'npge.block.hasRepeats'
            hasRepeats(B({
                F(g1c1, 1, 1, 1),
            }))
        end)
    end)
end)
