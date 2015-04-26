-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

describe("npge.util.textToIt", function()
    it("creates lines iterator from text", function()
        local textToIt = require 'npge.util.textToIt'
        local it = textToIt("1\n2\n3")
        assert.equal(it(), "1")
        assert.equal(it(), "2")
        assert.equal(it(), "3")
        assert.falsy(it())
    end)
end)
