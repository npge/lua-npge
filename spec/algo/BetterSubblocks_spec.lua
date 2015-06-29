-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

describe("npge.algo.BetterSubblocks", function()
    local revert

    before_each(function()
        local config = require 'npge.config'
        revert = config:updateKeys({
            general = {
                MIN_LENGTH = 10,
                FRAME_LENGTH = 10,
                MIN_IDENTITY = 0.9,
                MIN_END = 3,
            },
        })
    end)

    after_each(function()
        revert()
    end)

    it("extracts good blocks not overlapping with other bs.",
    function()
        -- AAAAAAAAAAAAAAAAAAAAAAAA
        -- AAAAAAAAAAATTAAAAAAAAAAA
        --           ****
        -- * - overlap with other blockset (10-13)
        local S = require 'npge.model.Sequence'
        local s1 = S('s1', "AAAAAAAAAAAAAAAAAAAAAAAA")
        local s2 = S('s2', "AAAAAAAAAAATTAAAAAAAAAAA")
        local s3 = S('s3', "AAAAAAAAAAATTAAAAAAAAAAA")
        local F = require 'npge.model.Fragment'
        local B = require 'npge.model.Block'
        local BS = require 'npge.model.BlockSet'
        local current = B {
            F(s1, 0, s1:length() - 1, 1),
            F(s2, 0, s2:length() - 1, 1),
        }
        local other = B {
            F(s1, 13, 10, -1), -- let it be negative
            F(s2, 13, 10, -1),
            F(s3, 13, 10, -1),
        }
        local Better = require 'npge.algo.BetterSubblocks'
        local better = Better(
            BS({s1, s2, s3}, {current}),
            BS({s1, s2, s3}, {other})
        )
        assert.truthy(#better:blocks() >= 1)
        local bb = better:blocks()[1]
        local isGood = require 'npge.block.isGood'
        assert.truthy(isGood(bb))
        local consensus = require 'npge.block.consensus'
        assert.equal(consensus(bb), "AAAAAAAAAA")
    end)
end)
