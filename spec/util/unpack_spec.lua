-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2016 Boris Nagaev
-- See the LICENSE file for terms of use.

local npge = require 'npge'
local unpack = npge.util.unpack

describe("npge.util.unpack", function()
    it("unpack works", function()
        local a, b = unpack({1, 2})
        assert.are.same({a, b}, {1, 2})
    end)
end)
