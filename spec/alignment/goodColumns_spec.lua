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

    it("returns empty table if input is empty", function()
        local goodColumns = require 'npge.cpp'.func.goodColumns
        assert.same(goodColumns({}), {})
        assert.same(goodColumns({""}), {})
        assert.same(goodColumns({"", ""}), {})
    end)

    it("can return statuses for slice", function()
        local goodColumns = require 'npge.cpp'.func.goodColumns
        assert.same(goodColumns({
            "AAT-AG",
            "ACTGTG",
            "ACTG-G",
        }, 1, 3), {false, true, false})
        assert.same(goodColumns({
            "AAT-AG",
            "ACTGTG",
            "ACTG-G",
        }, 1), {false, true, false, false, true})
    end)

    it("throws for invalid input", function()
        local goodColumns = require 'npge.cpp'.func.goodColumns
        assert.has_error(function()
            goodColumns({
                "AAT-AG",
                "ACTGTGA",
            })
        end)
        assert.has_error(function()
            goodColumns({
                "AAT-AG",
                "",
            })
        end)
        assert.has_error(function()
            goodColumns({
                "AAT-AG",
                "ACTG-G",
            }, -1, 2)
        end)
        assert.has_error(function()
            goodColumns({
                "AAT-AG",
                "ACTG-G",
            }, 0, 6)
        end)
    end)
end)
