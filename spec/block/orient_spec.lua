-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

describe("npge.block.orient", function()
    it("orients block to maximize number of positive fragments",
    function()
        local model = require 'npge.model'
        local s = model.Sequence("test_name", "AATAT")
        local block = model.Block({
            model.Fragment(s, 0, 2, 1),
        })
        local orient = require 'npge.block.orient'
        assert.equal(orient(block), block)
    end)

    it("orients block (1 fragment, ori = -1)",
    function()
        local model = require 'npge.model'
        local s = model.Sequence("test_name", "AATAT")
        local block = model.Block({
            model.Fragment(s, 2, 0, -1),
        })
        local orient = require 'npge.block.orient'
        local reverse = require 'npge.block.reverse'
        assert.equal(orient(block), reverse(block))
        assert.not_equal(orient(block), block)
    end)

    it("orients block (2 fragments, ori = 1)",
    function()
        local model = require 'npge.model'
        local s = model.Sequence("test_name", "AATAT")
        local block = model.Block({
            model.Fragment(s, 0, 2, 1),
            model.Fragment(s, 3, 4, 1),
        })
        local orient = require 'npge.block.orient'
        assert.equal(orient(block), block)
    end)

    it("orients block (2 fragments, ori = -1)",
    function()
        local model = require 'npge.model'
        local s = model.Sequence("test_name", "AATAT")
        local block = model.Block({
            model.Fragment(s, 2, 0, -1),
            model.Fragment(s, 4, 3, -1),
        })
        local orient = require 'npge.block.orient'
        local reverse = require 'npge.block.reverse'
        assert.equal(orient(block), reverse(block))
    end)

    it("orients block (2 fragments, ori = 1 and -1)",
    function()
        local model = require 'npge.model'
        local s = model.Sequence("test_name", "AATAT")
        local block = model.Block({
            model.Fragment(s, 2, 0, -1),
            model.Fragment(s, 3, 4, 1),
        })
        -- reverse, because minimum fragment is negative
        local orient = require 'npge.block.orient'
        local reverse = require 'npge.block.reverse'
        assert.equal(orient(block), reverse(block))
    end)

    it("orients block (2 fragments, ori = 1 and -1, 2nd)",
    function()
        local model = require 'npge.model'
        local s = model.Sequence("test_name", "AATAT")
        local block = model.Block({
            model.Fragment(s, 0, 2, 1),
            model.Fragment(s, 4, 3, -1),
        })
        -- not reverse, because minimum fragment is positive
        local orient = require 'npge.block.orient'
        assert.equal(orient(block), block)
    end)
end)
