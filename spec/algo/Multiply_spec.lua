-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

describe("npge.algo.Multiply", function()

    it("small example", function()
        local model = require 'npge.model'
        local s1 = model.Sequence("g1&c&c", "ATGC")
        local s2 = model.Sequence("g2&c&c", "ATC")
        local bs1 = model.BlockSet({s1, s2}, {
            model.Block({
                model.Fragment(s1, 0, 2, 1),
                model.Fragment(s2, 0, 1, 1),
            }),
            model.Block({
                model.Fragment(s1, 3, 3, 1),
                model.Fragment(s2, 2, 2, 1),
            }),
        })
        local bs2 = model.BlockSet({s1, s2}, {
            model.Block({
                model.Fragment(s1, 0, 1, 1),
                model.Fragment(s2, 0, 1, 1),
            }),
            model.Block({
                model.Fragment(s1, 2, 3, 1),
                model.Fragment(s2, 2, 2, 1),
            }),
        })
        local Multiply = require 'npge.algo.Multiply'
        local mul = Multiply(bs1, bs2)
        assert.equal(
            mul,
            model.BlockSet({s1, s2}, {
                model.Block({
                    model.Fragment(s1, 0, 1, 1),
                    model.Fragment(s2, 0, 1, 1),
                }),
                model.Block({
                    model.Fragment(s1, 2, 2, 1),
                }),
                model.Block({
                    model.Fragment(s1, 3, 3, 1),
                    model.Fragment(s2, 2, 2, 1),
                }),
            })
        )

        local SM = require 'npge.algo.SplitMultiplication'
        local common, conflicts = SM(bs1, bs2, mul)
        assert.equal(
            common,
            model.BlockSet({s1, s2}, {
                model.Block({
                    model.Fragment(s1, 0, 1, 1),
                    model.Fragment(s2, 0, 1, 1),
                }),
                model.Block({
                    model.Fragment(s1, 3, 3, 1),
                    model.Fragment(s2, 2, 2, 1),
                }),
            })
        )
        assert.equal(
            conflicts,
            model.BlockSet({s1, s2}, {
                model.Block({
                    model.Fragment(s1, 2, 2, 1),
                }),
            })
        )

        local NpgDistance = require 'npge.algo.NpgDistance'
        local abs_dist, rel_dist = NpgDistance(
            bs1, bs2, conflicts, common
        )
        -- not counted, because they are minor
        assert.equal(abs_dist, 0)
        assert.equal(rel_dist, 0)
        local config = require 'npge.config'
        local revert = config:updateKeys({
            general = {
                MIN_LENGTH = 1,
            },
        })
        local abs_dist, rel_dist = NpgDistance(
            bs1, bs2, conflicts, common
        )
        assert.equal(abs_dist, 1)
        assert.equal(rel_dist, 1 / 7)
        revert()
    end)

    it("respects ori of first blockset", function()
        local model = require 'npge.model'
        local s1 = model.Sequence("g1&c&c", "ATGC")
        local bs1 = model.BlockSet({s1}, {
            model.Block({
                model.Fragment(s1, 0, 3, 1),
            }),
        })
        local bs2 = model.BlockSet({s1}, {
            model.Block({
                model.Fragment(s1, 3, 0, -1),
            }),
        })
        local Multiply = require 'npge.algo.Multiply'
        assert.equal(
            Multiply(bs1, bs2),
            model.BlockSet({s1}, {
                model.Block({
                    model.Fragment(s1, 0, 3, 1),
                }),
            })
        )
    end)

    it("throws if a blockset is not a partition", function()
        local model = require 'npge.model'
        local s1 = model.Sequence("g1&c&c", "ATGC")
        local partition = model.BlockSet({s1}, {
            model.Block({
                model.Fragment(s1, 0, 3, 1),
            }),
        })
        local not_partition = model.BlockSet({s1}, {
            model.Block({
                model.Fragment(s1, 0, 2, 1),
            }),
        })
        local Multiply = require 'npge.algo.Multiply'
        assert.has_no_error(function()
            Multiply(partition, partition)
        end)
        assert.has_error(function()
            Multiply(partition, not_partition)
        end)
        assert.has_error(function()
            Multiply(not_partition, partition)
        end)
        assert.has_error(function()
            Multiply(not_partition, not_partition)
        end)
    end)

    it("throws if blocksets use different sets of sequences",
    function()
        local model = require 'npge.model'
        local s1 = model.Sequence("g1&c&c", "ATGC")
        local s2 = model.Sequence("g2&c&c", "ATC")
        local bs1 = model.BlockSet({s1, s2}, {
            model.Block({
                model.Fragment(s1, 0, 3, 1),
                model.Fragment(s2, 0, 2, 1),
            }),
        })
        local bs2 = model.BlockSet({s1}, {
            model.Block({
                model.Fragment(s1, 0, 3, 1),
            }),
        })
        local Multiply = require 'npge.algo.Multiply'
        assert.has_no_error(function()
            Multiply(bs1, bs1)
            Multiply(bs2, bs2)
        end)
        assert.has_error(function()
            Multiply(bs1, bs2)
        end)
    end)

    it("applied to #mosses", function()
        local bs1 = dofile 'spec/sample_pangenome.lua'
        local bs2 = dofile 'spec/sample_pangenome2.lua'
        local Multiply = require 'npge.algo.Multiply'
        local m = Multiply(bs1, bs2)
        assert.equal(m:size(), 737)

        local SM = require 'npge.algo.SplitMultiplication'
        local common, conflicts = SM(bs1, bs2, m)
        assert.equal(common:size(), 494)
        assert.equal(conflicts:size(), 243)

        local Merge = require 'npge.algo.Merge'
        local m1 = Merge({common, conflicts})
        assert.equal(m1, m)
        local Overlapping = require 'npge.algo.Overlapping'
        for b in m:iterBlocks() do
            for f in b:iterFragments() do
                local oo1 = bs1:overlappingFragments(f)
                local oo2 = bs2:overlappingFragments(f)
                assert.equal(#oo1, 1)
                assert.equal(#oo2, 1)
                -- make sure that ori matches ori of bs1
                assert.equal(oo1[1]:ori(), f:ori())
            end
            local bb1 = Overlapping(bs1, b)
            local bb2 = Overlapping(bs2, b)
            assert.equal(#bb1, 1)
            assert.equal(#bb2, 1)
        end

        local NpgDistance = require 'npge.algo.NpgDistance'
        local abs_dist, rel_dist = NpgDistance(
            bs1, bs2, conflicts, common
        )
        assert.equal(abs_dist, 611)
        assert.equal(rel_dist, 611 / 323637)
    end)

end)
