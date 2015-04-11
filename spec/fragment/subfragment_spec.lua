-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

describe("npge.fragment.sub model.subfragment", function()
    it("gets subfragment", function()
        local model = require 'npge.model'
        local s = model.Sequence("genome&chromosome&c", "ATGC")
        local f = model.Fragment(s, 1, 2, 1)
        local subfragment = require 'npge.fragment.subfragment'
        assert.are.equal(subfragment(f, 0, 0, 1):text(), "T")
        assert.are.equal(subfragment(f, 0, 0, -1):text(), "A")
        assert.are.equal(subfragment(f, 0, 1, 1):text(), "TG")
        assert.are.equal(subfragment(f, 1, 0, -1):text(), "CA")
        local f = model.Fragment(s, 2, 0, 1)
        assert.are.equal(subfragment(f, 0, 0, 1):text(), "G")
        assert.are.equal(subfragment(f, 0, 0, -1):text(), "C")
        assert.are.equal(subfragment(f, 0, 2, 1):text(), "GCA")
        assert.are.equal(subfragment(f, 2, 0, -1):text(), "TGC")
        --
        assert.has_error(function()
            subfragment(f, 1, 2, -1)
        end)
        --
        local f = model.Fragment(s, 0, 2, -1)
        local sub = require 'npge.fragment.sub'
        assert.are.equal(sub(f, 1, 2, 1), "GC")
    end)
end)
