-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2016 Boris Nagaev
-- See the LICENSE file for terms of use.

local cc = require 'npge.util.concatArrays'

describe("npge.util.concatArrays", function()
    it("check if arrays are concatenated", function()
        assert.same(cc({1, 2}, {3, 4}), {1, 2, 3, 4})
    end)
end)
