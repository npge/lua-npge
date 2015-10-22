-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

-- short form = consensuses + mutations
-- short form is sufficient to recover full form

describe("npge.fragment.parseId", function()
    it("gets sequence and coordinates from fragment id",
    function()
        local parseId = require 'npge.fragment.parseId'
        assert.same({parseId("A_0_100_1")}, {"A", 0, 100, 1})
        assert.same({parseId("A_0_100_-1")}, {"A", 0, 100, -1})
        assert.same({parseId("g&c&c_0_100_1")},
            {"g&c&c", 0, 100, 1})
    end)

    it("understands old id fromat", function()
        local parseId = require 'npge.fragment.parseId'
        assert.same({parseId("A_0_100")}, {"A", 0, 100, 1})
        assert.same({parseId("A_100_0")}, {"A", 100, 0, -1})
        assert.same({parseId("A_100_-1")}, {"A", 100, 100, -1})
        assert.same({parseId("A_10_9")}, {"A", 10, 9, -1})
    end)

    it("returns nil if argument doesn't match", function()
        local parseId = require 'npge.fragment.parseId'
        assert.falsy(parseId(" A_1_1_1"))
        assert.falsy(parseId("A_1_1_1 "))
        assert.falsy(parseId("A_B_C_D"))
        assert.falsy(parseId("A__1_1"))
        assert.falsy(parseId("A_1__1"))
        assert.falsy(parseId("A_1_1_"))
        assert.falsy(parseId("_1_1_1"))
        assert.falsy(parseId("A_B_C"))
        assert.falsy(parseId("A__1"))
        assert.falsy(parseId("A_1_"))
        assert.falsy(parseId("_1_1"))
    end)
end)
