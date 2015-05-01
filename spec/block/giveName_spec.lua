-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

describe("npge.block.giveName", function()
    it("generates name for block", function()
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
        local giveName = require 'npge.block.giveName'
        assert.equal(giveName(B({
            F(g1c1, 1, 1, 1),
        }), genomes_number), "m1x1")
        assert.equal(giveName(B({
            F(g1c1, 1, 1, 1),
            F(g1c1, 2, 2, 1),
        }), genomes_number), "m2x1")
        assert.equal(giveName(B({
            F(g1c1, 0, 400, 1),
        }), genomes_number), "u1x401")
        assert.equal(giveName(B({
            F(g1c1, 1, 100, 1),
        }), genomes_number), "u1x100")
        assert.equal(giveName(B({
            F(g1c1, 1, 99, 1),
        }), genomes_number), "m1x99")
        assert.equal(giveName(B({
            F(g1c1, 1, 99, 1),
            F(g2c1, 1, 99, 1),
        }), genomes_number), "m2x99")
        assert.equal(giveName(B({
            F(g1c1, 1, 200, 1),
            F(g1c1, 51, 250, 1),
        }), genomes_number), "r2x200")
        assert.equal(giveName(B({
            F(g1c1, 1, 200, 1),
            F(g2c1, 51, 250, 1),
        }), genomes_number), "h2x200")
        assert.equal(giveName(B({
            F(g1c1, 1, 200, 1),
            F(g1c1, 51, 250, 1),
            F(g2c1, 51, 250, 1),
        }), genomes_number), "r3x200")
        assert.equal(giveName(B({
            F(g1c1, 1, 200, 1),
            F(g2c1, 51, 250, 1),
            F(g3c1, 51, 250, 1),
        }), genomes_number), "s3x200")
        assert.equal(giveName(B({
            F(g1c1, 1, 200, 1),
            F(g1c1, 51, 250, 1),
            F(g2c1, 1, 200, 1),
            F(g2c1, 51, 250, 1),
            F(g3c1, 1, 200, 1),
            F(g3c1, 51, 250, 1),
        }), genomes_number), "r6x200")
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
            local giveName = require 'npge.block.giveName'
            giveName(B({
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
            local giveName = require 'npge.block.giveName'
            giveName(B({
                F(g1c1, 1, 200, 1),
                F(g1c1, 201, 400, 1),
                F(g1c1, 401, 600, 1),
            }))
        end)
        --
        revert()
    end)
end)
