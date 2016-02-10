-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2016 Boris Nagaev
-- See the LICENSE file for terms of use.

describe("npge.util.endsWith", function()
    it("check if a string has a suffix", function()
        local endsWith = require 'npge.util.endsWith'
        assert.truthy(endsWith("asdfg", "dfg"))
        assert.truthy(endsWith("asdfg", "g"))
        assert.truthy(endsWith("asdfg", ""))
        assert.truthy(endsWith("asdfg", "asdfg"))
        assert.falsy(endsWith("asdfg", "asd"))
        assert.falsy(endsWith("asdfg", "df"))
        assert.falsy(endsWith("asdfg", "a"))
    end)
end)
