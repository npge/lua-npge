-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2016 Boris Nagaev
-- See the LICENSE file for terms of use.

describe("npge.block.refine", function()
    it("refines alignment inside a block", function()
        local refine = require 'npge.block.refine'
        local m = require 'npge.model'
        local s1 = m.Sequence("s1", "AATTCAGG-ATCAAAAAT")
        local f1 = m.Fragment(s1, 0, s1:length() - 1, 1)
        local s2 = m.Sequence("s1", "AATTCAGGAATCAAAAAT")
        local f2 = m.Fragment(s2, 0, s2:length() - 1, 1)
        assert.not_equal(m.Block {
            {f1, "AATTCAGG-ATCAAAAAT"},
            {f1, "AATTCAGG-ATCAAAAAT"},
            {f1, "AATTCAGGA-TCAAAAAT"},
            {f2, "AATTCAGGAATCAAAAAT"},
        }, m.Block {
            {f1, "AATTCAGG-ATCAAAAAT"},
            {f1, "AATTCAGG-ATCAAAAAT"},
            {f1, "AATTCAGG-ATCAAAAAT"},
            {f2, "AATTCAGGAATCAAAAAT"},
        })
        assert.equal(refine(m.Block {
            {f1, "AATTCAGG-ATCAAAAAT"},
            {f1, "AATTCAGG-ATCAAAAAT"},
            {f1, "AATTCAGGA-TCAAAAAT"},
            {f2, "AATTCAGGAATCAAAAAT"},
        }), m.Block {
            {f1, "AATTCAGG-ATCAAAAAT"},
            {f1, "AATTCAGG-ATCAAAAAT"},
            {f1, "AATTCAGG-ATCAAAAAT"},
            {f2, "AATTCAGGAATCAAAAAT"},
        })
    end)
end)

