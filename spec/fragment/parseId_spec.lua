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
end)
