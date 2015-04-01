-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

describe("util.starts_with", function()
    it("check if a string has a prefix", function()
        local starts_with = require 'npge.util.starts_with'
        assert.truthy(starts_with("asdfg", "asd"))
        assert.truthy(starts_with("asdfg", "a"))
        assert.truthy(starts_with("asdfg", ""))
        assert.truthy(starts_with("asdfg", "asdfg"))
        assert.falsy(starts_with("asdfg", "sad"))
        assert.falsy(starts_with("asdfg", "sd"))
        assert.falsy(starts_with("asdfg", "dfg"))
    end)
end)
