-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

local arraysLess = require 'npge.util.arraysLess'

describe("npge.util.arraysLess", function()
    it("checks if one array is less than another", function()
        assert.is_false(arraysLess({1, 2}, {1, 2}))
        assert.is_true(arraysLess({1, 1}, {1, 2}))
        assert.is_true(arraysLess({0, 2}, {1, 2}))
        assert.is_false(arraysLess({4, 2}, {1, 2}))
        assert.has_error(function()
            arraysLess({1, 2}, {1, 2, 3})
        end)
    end)
end)
