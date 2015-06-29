-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

describe("npge.alignment.minIdentical", function()
    it("rounds properly", function()
        local minId = require 'npge.alignment.minIdentical'
        assert.equal(minId(0.55), 55)
        assert.equal(minId(0.54), 54)
        assert.equal(minId(0.56), 56)
        assert.equal(minId(0.551), 55)
        assert.equal(minId(0.549), 55)
    end)
end)
