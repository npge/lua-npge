-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

local unique = require 'npge.util.unique'

describe("util.unique", function()
    it("check if unique items are filtered", function()
        assert.same(unique({1, 2, 2, 4}), {1, 2, 4})
    end)
end)
