-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

describe("npge.alignment.goodSlices", function()
    it("finds good slices", function()
        local goodSlices = require 'npge.alignment.goodSlices'
        assert.same(goodSlices({true, false, true, true, true,
            false, false, false, false, true, true, true},
            3, 1, 0.6), {
                {start = 0, length = 5},
                {start = 9, length = 3},
            })
        assert.same(goodSlices({true, false, true, true, true,
            false, false, false, false, true, true, true, true},
            3, 2, 0.6), {
                {start = 9, length = 4},
                {start = 2, length = 3},
            })
    end)

    local function bools(row)
        row = row:gsub('%s', '')
        local array = {}
        for i = 1, #row do
            table.insert(array, row:sub(i, i) ~= '-')
        end
        return array
    end

    it("finds good slices (rows)", function()
        local goodSlices = require 'npge.alignment.goodSlices'
        assert.same(goodSlices(bools("+-+++----++++"),
            3, 1, 0.6), {
                {start = 0, length = 5},
                {start = 9, length = 4},
            })
        assert.same(goodSlices(bools("+-+++----++++"),
            3, 2, 0.6), {
                {start = 9, length = 4},
                {start = 2, length = 3},
            })
    end)

    it("finds good slices (long rows)", function()
        local goodSlices = require 'npge.alignment.goodSlices'
        local row = [[
++++++++++++++++++++-+++++++++++++++++++++++++++-++-++++--+-
+++++++++++-++++++++++++++++++++++++++++++++++++++++++++++++
++++++++++++++++++++-+-+++++++++-++--+++++-++++++-+--+++++++
+++++-++++++++-++++++++++++++-++++++++-++++++++++++++++-++++
+++++++-+++++++++++++++++-+++-+++++++++++-++++++++++++++++++
+++++++++++++++++++++++++++++++++++++++++-+++++-++++++++++++
+++++++++++++-++++++-++++++--+++++--++++++++++++++++++++--++
+++++++++-+++++++++++++++++++++-+++++++++++++-+++++++++++--+
++++--++++++++++++++++++++++++++++++++++++++++++++++++++++++
+++++-+++++++-++++++++-+++++++--++++++++++++++++++++++++++++
++++++++++++++++++++++-+++-+-+++++++++++++++++++++++++++++++
+++-+++++++-++++++++-+++++-++++++++-+++++++++++-+++++-++-+++
+++++++++++++-++++++++++++++++-+++++++++-+++++++++---++++++-
+++--+++-++++++-++++-++++++-+++++-++++++++++-+++++++++++++-+
++++++-+++-+++++--+++++++++++++++++-+++++++++++++-++++++++++
+++++++++++++++++++++++++-+++++-+++++++++++++++++++-++++++++
++++++++++++-++++++-++++++++++++++++++++]]
        assert.same(goodSlices(bools(row), 100, 3, 0.9), {
            {start = 396, length = 317},
            {start = 157, length = 237},
            {start = 801, length = 199},
            {start = 0, length = 152},
        })
    end)
end)
