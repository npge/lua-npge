-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2016 Boris Nagaev
-- See the LICENSE file for terms of use.

describe("npge.util.itFromArray", function()
    it("makes an iterator from an array", function()
        local itFromArray = require 'npge.util.itFromArray'
        local x = {1, 2}
        local it = itFromArray(x)
        local copy = {}
        for item in it do
            table.insert(copy, item)
        end
        assert.same(copy, x)
    end)
end)
