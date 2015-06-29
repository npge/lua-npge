-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

describe("npge.block.betterSubblocks", function()

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

    it("selects good part not overlapping with better blocks",
    function()
        local m = require 'npge.model'
        local s1 = m.Sequence("s1",
            "ATGCCATATGGTTGTCTTGCCTCCTTCAAACAGGATGTTCCATA")
        local s2 = m.Sequence("s2",
            "ATGCCATATGGTTGTCTTGCCTCCTTCAAACAGGATGTTCCATA")
        local s3 = m.Sequence("s3",
            "tacctggagactacattctcgaaataGAAACAGGATGTTCCATA")
        local s4 = m.Sequence("s4",
            "tacctggagactacattctcgaaataGAAACAGGATGTTCCATA")
        local bs = m.BlockSet({s1, s2, s3, s4}, {
            m.Block {
                m.Fragment(s1, 0, 25, 1),
                m.Fragment(s2, 0, 25, 1),
            },
            m.Block {
                m.Fragment(s1, 26, 43, 1),
                m.Fragment(s2, 26, 43, 1),
                m.Fragment(s3, 26, 43, 1),
                m.Fragment(s4, 26, 43, 1),
            },
            -- this block is less than expected block
            m.Block {
                m.Fragment(s3, 0, 5, 1),
                m.Fragment(s4, 0, 5, 1),
            }
        })
        local block = m.Block {
            m.Fragment(s1, 0, 43, 1),
            m.Fragment(s2, 0, 43, 1),
            m.Fragment(s3, 0, 43, 1),
            m.Fragment(s4, 0, 43, 1),
        }
        --
        local betterSB = require 'npge.block.betterSubblocks'
        local better = betterSB(block, bs)
        assert.same(better, {
            m.Block {
                m.Fragment(s3, 0, 25, 1),
                m.Fragment(s4, 0, 25, 1),
            },
        })
    end)
end)
