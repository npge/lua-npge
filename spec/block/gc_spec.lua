-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

describe("npge.block.c", function()
    it("finds part of GC in a block", function()
        local gc = require 'npge.block.gc'
        local model = require 'npge.model'
        local s1 = model.Sequence('s1', 'AAAA')
        local s2 = model.Sequence('s2', 'CCCC')
        local f1 = model.Fragment(s1, 0, 3, 1)
        local f2 = model.Fragment(s2, 0, 3, 1)
        local b = model.Block({f1, f2})
        assert.equal(gc(b), 0.5)
    end)

    it("returns 0 if no A,T,G,C were found in a block",
    function()
        local gc = require 'npge.block.gc'
        local model = require 'npge.model'
        local s1 = model.Sequence('s1', 'NNNN')
        local f1 = model.Fragment(s1, 0, 3, 1)
        local b = model.Block({f1})
        assert.equal(gc(b), 0)
    end)
end)
