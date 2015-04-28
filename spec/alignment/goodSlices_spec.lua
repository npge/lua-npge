-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

describe("npge.alignment.goodSlices", function()
    it("finds good slices", function()
        local goodSlices = require 'npge.alignment.goodSlices'
        assert.same(goodSlices({true, false, true, true, true,
            false, false, false, false, true, true, true},
            3, 1, 0.6), {
                {0, 4},
                {9, 11},
            })
        assert.same(goodSlices({true, false, true, true, true,
            false, false, false, false, true, true, true, true},
            3, 2, 0.6), {
                {9, 12},
                {2, 4},
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
                {0, 4},
                {9, 12},
            })
        assert.same(goodSlices(bools("+-+++----++++"),
            3, 2, 0.6), {
                {9, 12},
                {2, 4},
            })
    end)

    it("finds good slices (local is good, #global is bad)",
    function()
        local goodSlices = require 'npge.alignment.goodSlices'
        assert.same(goodSlices(bools("++-+++++++++-+"),
            10, 1, 0.9), {
                {0, 13}
            })
    end)

    it("finds good slices (min_length=length)",
    function()
        local goodSlices = require 'npge.alignment.goodSlices'
        assert.same(goodSlices(bools("+++"),
            3, 1, 0.9), {
                {0, 2}
            })
    end)

    it("finds good slices (min_length=length=min_end)",
    function()
        local goodSlices = require 'npge.alignment.goodSlices'
        assert.same(goodSlices(bools("+++"),
            3, 3, 0.9), {
                {0, 2}
            })
    end)

    it("finds good slices (min_end = 0)",
    function()
        local goodSlices = require 'npge.alignment.goodSlices'
        assert.same(goodSlices(bools("+++"),
            2, 0, 0.9), {
                {0, 2}
            })
    end)

    it("finds good slices (min_identity = 100%)",
    function()
        local goodSlices = require 'npge.alignment.goodSlices'
        assert.same(goodSlices(bools("+++"),
            2, 1, 1.0), {
                {0, 2}
            })
    end)

    it("finds good slices (min_identity = 0%)",
    function()
        local goodSlices = require 'npge.alignment.goodSlices'
        assert.same(goodSlices(bools("+-+"),
            2, 1, 0.0), {
                {0, 2}
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
            {396, 712},
            {157, 393},
            {801, 999},
            {0, 151},
        })
    end)
end)
