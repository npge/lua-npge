-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

describe("npge.util.mapItems", function()
    it("map items to ngroups groups of almost equal size",
    function()
        local mapItems = require 'npge.util.mapItems'
        local array = {1,2,5,7,8,10}
        local groups = mapItems(2, array)
        assert.equal(#groups, 2)
        assert.equal(#groups[1] + #groups[2], #array)
        assert.truthy(#groups[1] == #array / 2 or
                      #groups[1] == #array / 2 + 1)
        local array2 = {}
        for _, group in ipairs(groups) do
            for _, item in ipairs(group) do
                table.insert(array2, item)
            end
        end
        table.sort(array2)
        assert.same(array2, array)
    end)

    it("map items to one group", function()
        local mapItems = require 'npge.util.mapItems'
        local array = {1,2,5,7,8,10}
        local groups = mapItems(1, array)
        assert.equal(#groups, 1)
        local array2 = groups[1]
        assert.equal(#array2, #array)
        table.sort(array2)
        assert.same(array2, array)
    end)
end)
