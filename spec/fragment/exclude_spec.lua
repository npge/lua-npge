-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

describe("npge.fragment.exclude", function()
    it("excludes overlapping part from a fragment", function()
        local m = require 'npge.model'
        local F = m.Fragment
        local seq = m.Sequence("seq", "ATAT")
        local exclude = require 'npge.fragment.exclude'
        assert.equal(exclude(F(seq, 0, 3, 1),
            F(seq, 3, 3, 1)),
            F(seq, 0, 2, 1))
        assert.equal(exclude(F(seq, 0, 3, 1),
            F(seq, 0, 0, 1)),
            F(seq, 1, 3, 1))
    end)

    it("keeps orientation of minuend fragment", function()
        local m = require 'npge.model'
        local F = m.Fragment
        local seq = m.Sequence("seq", "ATAT")
        local exclude = require 'npge.fragment.exclude'
        assert.equal(exclude(F(seq, 0, 3, 1),
            F(seq, 3, 3, -1)),
            F(seq, 0, 2, 1))
        assert.equal(exclude(F(seq, 0, 3, 1),
            F(seq, 0, 0, -1)),
            F(seq, 1, 3, 1))
        assert.equal(exclude(F(seq, 3, 0, -1),
            F(seq, 3, 3, 1)),
            F(seq, 2, 0, -1))
        assert.equal(exclude(F(seq, 3, 0, -1),
            F(seq, 0, 0, 1)),
            F(seq, 3, 1, -1))
    end)

    it("excludes from middle -- select larger part", function()
        local m = require 'npge.model'
        local F = m.Fragment
        local seq = m.Sequence("seq", "ATAT")
        local exclude = require 'npge.fragment.exclude'
        assert.equal(exclude(F(seq, 0, 3, 1),
            F(seq, 1, 1, 1)),
            F(seq, 2, 3, 1))
    end)

    it("excludes parted fragment from non parted", function()
        local m = require 'npge.model'
        local F = m.Fragment
        local seq = m.Sequence("g&c&c", "ATAT")
        local exclude = require 'npge.fragment.exclude'
        assert.equal(exclude(F(seq, 0, 3, 1),
            F(seq, 3, 0, 1)),
            F(seq, 1, 2, 1))
        assert.equal(exclude(F(seq, 0, 3, 1),
            F(seq, 0, 3, -1)),
            F(seq, 1, 2, 1))
        assert.equal(exclude(F(seq, 3, 0, -1),
            F(seq, 3, 0, 1)),
            F(seq, 2, 1, -1))
    end)

    it("excludes non parted fragment from parted", function()
        local m = require 'npge.model'
        local F = m.Fragment
        local seq = m.Sequence("g&c&c", "ATAT")
        local exclude = require 'npge.fragment.exclude'
        assert.equal(exclude(F(seq, 2, 1, 1),
            F(seq, 0, 1, 1)),
            F(seq, 2, 3, 1))
        assert.equal(exclude(F(seq, 2, 1, 1),
            F(seq, 2, 3, 1)),
            F(seq, 0, 1, 1))
        -- ori
        assert.equal(exclude(F(seq, 2, 1, 1),
            F(seq, 1, 0, -1)),
            F(seq, 2, 3, 1))
        assert.equal(exclude(F(seq, 2, 1, 1),
            F(seq, 3, 2, -1)),
            F(seq, 0, 1, 1))
        -- from middle
        assert.equal(exclude(F(seq, 2, 1, 1),
            F(seq, 0, 0, 1)),
            F(seq, 2, 3, 1))
        assert.equal(exclude(F(seq, 2, 1, 1),
            F(seq, 1, 1, 1)),
            F(seq, 2, 0, 1))
        assert.equal(exclude(F(seq, 2, 1, 1),
            F(seq, 2, 2, 1)),
            F(seq, 3, 1, 1))
        assert.equal(exclude(F(seq, 2, 1, 1),
            F(seq, 3, 3, 1)),
            F(seq, 0, 1, 1))
        -- begin and end
        assert.equal(exclude(F(seq, 2, 1, 1),
            F(seq, 1, 2, 1)),
            F(seq, 3, 0, 1))
    end)

    it("excludes parted fragment from parted", function()
        local m = require 'npge.model'
        local F = m.Fragment
        local seq = m.Sequence("g&c&c", "ATATA")
        local exclude = require 'npge.fragment.exclude'
        assert.equal(exclude(F(seq, 2, 1, 1),
            F(seq, 4, 0, 1)),
            F(seq, 2, 3, 1))
    end)
end)
