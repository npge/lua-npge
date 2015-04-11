-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

local arrays_equal = require 'npge.util.arrays_equal'

describe("npge.util.arrays_equal", function()
    it("checks if arrays are equal", function()
        assert.is_true(arrays_equal({1, 2}, {1, 2}))
        assert.is_false(arrays_equal({1, 2}, {1, 2, 3}))
        assert.is_false(arrays_equal({1, 2}, {1, 0}))
    end)
end)
