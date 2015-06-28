-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

describe("npge.alignment.goodColumns", function()
    it("gets type of alignment columns", function()
        local goodColumns = require 'npge.alignment.goodColumns'
        assert.same(goodColumns({
            "NAAATTTG--GG",
            "NA-ATTTG--GG",
        }), {false, true, false, true, true, true, true, true,
             false, false, true, true})
        assert.same(goodColumns({
            "AAT-AG",
            "ACTGTG",
            "ACTG-G",
        }), {true, false, true, false, false, true})
    end)

    it("returns empty table if input is empty", function()
        local goodColumns = require 'npge.alignment.goodColumns'
        assert.same(goodColumns({}), {})
        assert.same(goodColumns({""}), {})
        assert.same(goodColumns({"", ""}), {})
    end)

    it("throws for invalid input", function()
        local goodColumns = require 'npge.alignment.goodColumns'
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
    end)
end)
