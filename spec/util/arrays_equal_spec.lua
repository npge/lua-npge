-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2016 Boris Nagaev
-- See the LICENSE file for terms of use.

local arraysEqual = require 'npge.util.arraysEqual'

describe("npge.util.arraysEqual", function()
    it("checks if arrays are equal", function()
        assert.is_true(arraysEqual({1, 2}, {1, 2}))
        assert.is_false(arraysEqual({1, 2}, {1, 2, 3}))
        assert.is_false(arraysEqual({1, 2}, {1, 0}))
    end)
end)
