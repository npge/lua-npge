-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

describe("npge.block.identity", function()
    it("finds identity of block (100%)", function()
        local model = require 'npge.model'
        local s = model.Sequence("s", "ATAT")
        local f = model.Fragment(s, 0, 3, 1)
        local b = model.Block({f, f})
        local identity = require 'npge.block.identity'
        assert.equal(identity(b), 1)
    end)

    it("finds identity of block (50%)", function()
        local model = require 'npge.model'
        local s = model.Sequence("s", "ATTT")
        local f1 = model.Fragment(s, 0, 1, 1)
        local f2 = model.Fragment(s, 2, 3, 1)
        local b = model.Block({{f1, 'AT'}, {f2, 'TT'}})
        local identity = require 'npge.block.identity'
        assert.equal(identity(b), 0.5)
    end)

    it("finds identity of block (gap)", function()
        local model = require 'npge.model'
        local s = model.Sequence("s", "ATTT")
        local f1 = model.Fragment(s, 0, 1, 1)
        local f2 = model.Fragment(s, 3, 3, 1)
        local b = model.Block({{f1, 'AT'}, {f2, '-T'}})
        local identity = require 'npge.block.identity'
        assert.equal(identity(b), 0.5)
    end)
end)
