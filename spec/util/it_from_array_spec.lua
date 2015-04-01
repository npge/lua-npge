-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

describe("util.it_from_array", function()
    it("makes an iterator from an array", function()
        local it_from_array = require 'npge.util.it_from_array'
        local x = {1, 2}
        local it = it_from_array(x)
        local copy = {}
        for item in it do
            table.insert(copy, item)
        end
        assert.same(copy, x)
    end)
end)
