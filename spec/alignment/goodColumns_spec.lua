-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

describe("npge.cpp.func.goodColumns", function()
    it("gets type of alignment columns", function()
        local goodColumns = require 'npge.cpp'.func.goodColumns
        assert.same(goodColumns({
            "AAAATTTG--GG",
            "AA-ATTTG--GG",
        }), {true, true, false, true, true, true, true, true,
             false, false, true, true})
        assert.same(goodColumns({
            "AAT-AG",
            "ACTGTG",
            "ACTG-G",
        }), {true, false, true, false, false, true})
    end)
end)
