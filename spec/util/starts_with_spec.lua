-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2016 Boris Nagaev
-- See the LICENSE file for terms of use.

describe("npge.util.startsWith", function()
    it("check if a string has a prefix", function()
        local startsWith = require 'npge.util.startsWith'
        assert.truthy(startsWith("asdfg", "asd"))
        assert.truthy(startsWith("asdfg", "a"))
        assert.truthy(startsWith("asdfg", ""))
        assert.truthy(startsWith("asdfg", "asdfg"))
        assert.falsy(startsWith("asdfg", "sad"))
        assert.falsy(startsWith("asdfg", "sd"))
        assert.falsy(startsWith("asdfg", "dfg"))
    end)
end)
