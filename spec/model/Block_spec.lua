-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

local model = require 'npge.model'

describe("npge.model.Block", function()
    it("has type 'Block'", function()
        local s = model.Sequence("test_name", "ATAT")
        local f1 = model.Fragment(s, 0, 1, 1)
        local f2 = model.Fragment(s, 3, 2, -1)
        local block = model.Block({f1, f2})
        assert.equal(block:type(), 'Block')
    end)

    it("creates block without rows", function()
        local s = model.Sequence("test_name", "ATAT")
        local f1 = model.Fragment(s, 0, 1, 1)
        local f2 = model.Fragment(s, 3, 2, -1)
        local block = model.Block({f1, f2})
        assert.are.equal(block:size(), 2)
        assert.are.equal(block:length(), 2)
    end)

    it("creates block with rows", function()
        local s = model.Sequence("test_name", "AATAT")
        local f1 = model.Fragment(s, 0, 2, 1) -- AAT
        local f2 = model.Fragment(s, 4, 3, -1) -- AT
        local f3 = model.Fragment(s, 0, 1, 1) -- AA
        local block = model.Block({
            {f1, 'AAT'},
            {f2, 'A-T'},
            {f3, 'AA-'},
        })
        assert.are.equal(block:size(), 3)
        assert.are.equal(block:length(), 3)
        assert.are.equal(block:text(f1), 'AAT')
        assert.are.equal(block:text(f2), 'A-T')
        assert.are.equal(block:block2fragment(f1, 0), 0)
        assert.are.equal(block:block2fragment(f1, 1), 1)
        assert.are.equal(block:block2fragment(f1, 2), 2)
        assert.are.equal(block:block2fragment(f2, 0), 0)
        assert.are.equal(block:block2fragment(f2, 1), -1)
        assert.are.equal(block:block2fragment(f2, 2), 1)
        assert.are.equal(block:fragment2block(f1, 0), 0)
        assert.are.equal(block:fragment2block(f1, 1), 1)
        assert.are.equal(block:fragment2block(f1, 2), 2)
        assert.are.equal(block:fragment2block(f2, 0), 0)
        assert.are.equal(block:fragment2block(f2, 1), 2)
        assert.are.equal(block:block2left(f2, 0), 0)
        assert.are.equal(block:block2left(f2, 1), 0)
        assert.are.equal(block:block2left(f2, 2), 1)
        assert.are.equal(block:block2right(f2, 0), 0)
        assert.are.equal(block:block2right(f2, 1), 1)
        assert.are.equal(block:block2right(f2, 2), 1)
        assert.are.equal(block:block2right(f3, 0), 0)
        assert.are.equal(block:block2right(f3, 1), 1)
        assert.are.equal(block:block2right(f3, 2), -1)
    end)

    it("throws on out of range index for block2* methods",
    function()
        local s = model.Sequence("test_name", "AATAT")
        local f1 = model.Fragment(s, 0, 2, 1) -- AAT
        local block = model.Block({
            {f1, 'AAT'},
        })
        assert.has_error(function()
            block:block2fragment(f1, -1)
        end)
        assert.has_error(function()
            block:block2left(f1, -1)
        end)
        assert.has_error(function()
            block:block2right(f1, -1)
        end)
        assert.has_error(function()
            block:fragment2block(f1, -1)
        end)
        assert.has_error(function()
            block:block2fragment(f1, 3)
        end)
        assert.has_error(function()
            block:block2left(f1, 3)
        end)
        assert.has_error(function()
            block:block2right(f1, 3)
        end)
        assert.has_error(function()
            block:fragment2block(f1, 3)
        end)
    end)

    it("block:text(unknown fragment) throws", function()
        local s = model.Sequence("test_name", "AATAT")
        local f1 = model.Fragment(s, 0, 2, 1) -- AAT
        local f2 = model.Fragment(s, 4, 3, -1) -- AT
        local block = model.Block({f1})
        assert.has_error(function()
            block:text(f2)
        end)
    end)

    it("throws on poor formed blocks", function()
        local s = model.Sequence("test_name", "AATAT")
        local f1 = model.Fragment(s, 0, 2, 1) -- AAT
        local f2 = model.Fragment(s, 4, 3, -1) -- AT
        assert.has_error(function()
            local block = model.Block({})
        end)
        assert.has_error(function()
            local block = model.Block({
                f1,
                {f2, 'AT'},
            })
        end)
        assert.has_error(function()
            local block = model.Block({
                {f1, 'AAT'},
                {f2, 'AT'},
            })
        end)
        assert.has_error(function()
            local block = model.Block({
                {f1, ''},
                {f2, ''},
            })
        end)
        assert.has_error(function()
            local block = model.Block({
                {f1, ''},
                {f2, ''},
            })
        end)
    end)

    it("gets fragments of block", function()
        local s = model.Sequence("test_name", "ATAT")
        local f1 = model.Fragment(s, 0, 1, 1)
        local f2 = model.Fragment(s, 3, 2, -1)
        local ff1 = {f1, f2}
        local block = model.Block(ff1)
        local ff2 = block:fragments()
        table.sort(ff1)
        table.sort(ff2)
        assert.are.same(ff1, ff2)
    end)

    it("iterate fragments of block", function()
        local s = model.Sequence("test_name", "ATAT")
        local f1 = model.Fragment(s, 0, 1, 1)
        local f2 = model.Fragment(s, 3, 2, -1)
        local ff1 = {f1, f2}
        local block = model.Block(ff1)
        local ff2 = {}
        for f in block:iterFragments() do
            table.insert(ff2, f)
        end
        table.sort(ff1)
        table.sort(ff2)
        assert.are.same(ff1, ff2)
    end)

    it("compares blocks (==)", function()
        local s = model.Sequence("test_name", "ATAT")
        local f1 = model.Fragment(s, 0, 1, 1)
        local f2 = model.Fragment(s, 2, 3, 1)
        assert.equal(model.Block({f1, f2}),
            model.Block({f1, f2}))
        assert.equal(model.Block({{f1, 'AT'}, {f2, 'AT'}}),
            model.Block({f1, f2}))
        assert.equal(model.Block({{f1, 'AT'}, {f2, 'AT'}}),
            model.Block({{f1, 'AT'}, {f2, 'AT'}}))
        assert.not_equal(
            model.Block({{f1, 'AT'}, {f2, 'AT'}}),
            model.Block({{f1, 'A-T'}, {f2, 'AT-'}}))
        assert.not_equal(
            model.Block({{f1, 'AT'}, {f2, 'AT'}}),
            model.Block({{f1, 'AT'}}))
        assert.equal(
            model.Block({{f1, 'A-T'}, {f2, 'AT-'}}),
            model.Block({{f1, 'A-T'}, {f2, 'AT-'}}))
        assert.equal(
            model.Block({{f1, 'A-T'}, {f1, 'AT-'}}),
            model.Block({{f1, 'AT-'}, {f1, 'A-T'}}))
    end)

    it("compares blocks (<)", function()
        local s = model.Sequence("test_name", "ATAT")
        local f1 = model.Fragment(s, 0, 1, 1)
        local f2 = model.Fragment(s, 2, 3, 1)
        local b1 = model.Block({f1, f2})
        local b1_1 = model.Block({f1, f2})
        assert.falsy(b1 < b1_1)
        assert.falsy(b1_1 < b1)
        local b2 = model.Block({f1, f1})
        assert.truthy(b1 < b2 or b2 < b1)
        local b3 = model.Block({
            {f1, "AT-"},
            {f2, "A-T"},
        })
        assert.truthy(b1 < b3 or b3 < b1)
        local b4 = model.Block({f1, f1, f2})
        assert.truthy(b1 < b4 or b4 < b1)
    end)

    it("makes string representation of block", function()
        local s = model.Sequence("test_name", "ATAT")
        local f1 = model.Fragment(s, 0, 1, 1)
        local f2 = model.Fragment(s, 3, 2, -1)
        local block = model.Block({f1, f2})
        assert.truthy(tostring(block))
    end)
end)
