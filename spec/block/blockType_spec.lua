-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

describe("npge.block.blockType", function()
    it("gets type of block", function()
        local config = require 'npge.config'
        local revert = config:updateKeys({
            general = {
                MIN_LENGTH = 100,
                MIN_IDENTITY = 0.9,
                MIN_END = 3,
            },
        })
        --
        local model = require 'npge.model'
        local text = ("A"):rep(1000)
        local g1c1 = model.Sequence("g1&c1&c", text)
        local g2c1 = model.Sequence("g2&c1&c", text)
        local g3c1 = model.Sequence("g3&c1&c", text)
        local genomes_number = 3
        local F = model.Fragment
        local B = model.Block
        local blockType = require 'npge.block.blockType'
        assert.equal(blockType(B({
            F(g1c1, 1, 1, 1),
        }), genomes_number), "minor")
        assert.equal(blockType(B({
            F(g1c1, 1, 1, 1),
            F(g1c1, 2, 2, 1),
        }), genomes_number), "minor")
        assert.equal(blockType(B({
            F(g1c1, 0, 200, 1),
            F(g1c1, 200, 0, 1),
        }), genomes_number), "minor")
        assert.equal(blockType(B({
            F(g1c1, 0, 400, 1),
        }), genomes_number), "unique")
        assert.equal(blockType(B({
            F(g1c1, 1, 100, 1),
        }), genomes_number), "unique")
        assert.equal(blockType(B({
            F(g1c1, 1, 99, 1),
        }), genomes_number), "minor")
        assert.equal(blockType(B({
            F(g1c1, 1, 99, 1),
            F(g2c1, 1, 99, 1),
        }), genomes_number), "minor")
        assert.equal(blockType(B({
            F(g1c1, 1, 200, 1),
            F(g1c1, 51, 250, 1),
        }), genomes_number), "repeat")
        assert.equal(blockType(B({
            F(g1c1, 1, 200, 1),
            F(g2c1, 51, 250, 1),
        }), genomes_number), "half")
        assert.equal(blockType(B({
            F(g1c1, 1, 200, 1),
            F(g1c1, 51, 250, 1),
            F(g2c1, 51, 250, 1),
        }), genomes_number), "repeat")
        assert.equal(blockType(B({
            F(g1c1, 1, 200, 1),
            F(g2c1, 51, 250, 1),
            F(g3c1, 51, 250, 1),
        }), genomes_number), "stable")
        assert.equal(blockType(B({
            F(g1c1, 1, 200, 1),
            F(g1c1, 51, 250, 1),
            F(g2c1, 1, 200, 1),
            F(g2c1, 51, 250, 1),
            F(g3c1, 1, 200, 1),
            F(g3c1, 51, 250, 1),
        }), genomes_number), "repeat")
        --
        revert()
    end)

    it("throws if genomes are unknown", function()
        local config = require 'npge.config'
        local revert = config:updateKeys({
            general = {
                MIN_LENGTH = 100,
                MIN_IDENTITY = 0.9,
                MIN_END = 3,
            },
        })
        --
        assert.has_error(function()
            local text = ("A"):rep(1000)
            local model = require 'npge.model'
            local g1c1 = model.Sequence("g1c1c", text)
            local g2c1 = model.Sequence("g2c1c", text)
            local g3c1 = model.Sequence("g3c1c", text)
            local genomes_number = 3
            local F = model.Fragment
            local B = model.Block
            local blockType = require 'npge.block.blockType'
            blockType(B({
                F(g1c1, 1, 200, 1),
                F(g2c1, 1, 200, 1),
                F(g3c1, 1, 200, 1),
            }), genomes_number)
        end)
        --
        revert()
    end)

    it("throws if number of genomes was not provided",
    function()
        local config = require 'npge.config'
        local revert = config:updateKeys({
            general = {
                MIN_LENGTH = 100,
                MIN_IDENTITY = 0.9,
                MIN_END = 3,
            },
        })
        --
        assert.has_error(function()
            local text = ("A"):rep(1000)
            local model = require 'npge.model'
            local g1c1 = model.Sequence("g1c1c", text)
            local g2c1 = model.Sequence("g2c1c", text)
            local g3c1 = model.Sequence("g3c1c", text)
            local F = model.Fragment
            local B = model.Block
            local blockType = require 'npge.block.blockType'
            blockType(B({
                F(g1c1, 1, 200, 1),
                F(g1c1, 201, 400, 1),
                F(g1c1, 401, 600, 1),
            }))
        end)
        --
        revert()
    end)
end)
