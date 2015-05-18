-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

describe("npge.block.excludeBetterOrEqual", function()
    it("excludes parts overlapping with >= blocks", function()
        local m = require 'npge.model'
        local s = m.Sequence("s", "ATAT")
        local F = m.Fragment
        local B = m.Block
        local BS = m.BlockSet
        local e = require 'npge.block.excludeBetterOrEqual'
        assert.truthy(e(B {
            F(s, 0, 3, 1),
        }, BS({s}, {
            B {
                F(s, 2, 2, 1),
                F(s, 3, 3, 1),
            },
        })), B {
            F(s, 0, 1, 1),
        })
        --
        assert.truthy(e(B {
            F(s, 0, 3, 1),
        }, BS({s}, {
            B {
                F(s, 2, 2, 1),
            },
        })), B {
            F(s, 0, 3, 1),
        })
        --
        assert.truthy(e(B {
            F(s, 0, 2, 1),
        }, BS({s}, {
            B {
                F(s, 2, 3, 1),
            },
        })), B {
            F(s, 0, 1, 1),
        })
    end)

    it("replaces overlappings parts with gaps", function()
        local m = require 'npge.model'
        local s1 = m.Sequence("s1", "ATAT")
        local s2 = m.Sequence("s2", "ATAT")
        local s3 = m.Sequence("s3", "ATAT")
        local s4 = m.Sequence("s4", "ATAT")
        local F = m.Fragment
        local B = m.Block
        local BS = m.BlockSet
        local e = require 'npge.block.excludeBetterOrEqual'
        assert.truthy(e(B {
            {F(s1, 0, 1, 1), "AT"},
            {F(s2, 0, 1, 1), "AT"},
        }, BS({s1, s2, s3, s4}, {
            B {
                F(s2, 1, 3, 1),
                F(s3, 1, 3, 1),
                F(s4, 1, 3, 1),
            },
        })), B {
            {F(s1, 0, 1, 1), "AT"},
            {F(s2, 0, 0, 1), "A-"},
        })
    end)
end)
