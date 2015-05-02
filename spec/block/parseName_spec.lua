-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

describe("npge.block.parseName", function()
    it("parses generated name of block", function()
        local parseName = require 'npge.block.parseName'
        assert.same({parseName('s24x100')}, {'s', 24, 100})
        assert.falsy(parseName('24x100'))
        assert.same({parseName('s24x100n1')}, {'s', 24, 100, 1})
    end)
end)
