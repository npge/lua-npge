-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2016 Boris Nagaev
-- See the LICENSE file for terms of use.

describe("npge.block.removePureGaps", function()
    it("removes gap columns inside a block", function()
        local removePureGaps = require 'npge.block.removePureGaps'
        local m = require 'npge.model'
        local s1 = m.Sequence("s1", "AATTCAGGATCAAAAAT")
        local f1 = m.Fragment(s1, 0, s1:length() - 1, 1)
        local f2 = m.Fragment(s1, 0, s1:length() - 1, 1)
        assert.equal(removePureGaps(m.Block {
            {f1, "AATTCAGG-ATCAAAAAT"},
            {f2, "AATTCAGG-ATCAAAAAT"},
        }), m.Block {
            {f1, "AATTCAGGATCAAAAAT"},
            {f1, "AATTCAGGATCAAAAAT"},
        })
    end)
end)
