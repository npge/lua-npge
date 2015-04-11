-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

describe("npge.algo.HasOverlap", function()
    it("tests that blockset contains overlaps",
    function()
        local model = require 'npge.model'
        local s = model.Sequence("seq", "ATGC")
        local f1 = model.Fragment(s, 0, 1, 1)
        local f2 = model.Fragment(s, 1, 2, 1)
        local block = model.Block({f1, f2})
        local bs = model.BlockSet({s}, {block})
        local HasOverlap = require 'npge.algo.HasOverlap'
        local has, fr1, fr2 = HasOverlap(bs)
        assert.truthy(has)
        assert.equal(fr1:common(fr2), 1)
    end)

    it("tests that blockset contains no overlaps",
    function()
        local model = require 'npge.model'
        local s = model.Sequence("g&c&c", "ATGC")
        local f1 = model.Fragment(s, 3, 0, 1) -- parted
        local f2 = model.Fragment(s, 1, 2, 1)
        local block = model.Block({f1, f2})
        local bs = model.BlockSet({s}, {block})
        local HasOverlap = require 'npge.algo.HasOverlap'
        assert.falsy(HasOverlap(bs))
    end)

    it("tests that blockset contains overlaps (parted frag.)",
    function()
        local model = require 'npge.model'
        local s = model.Sequence("g&c&c", "ATGC")
        local f1 = model.Fragment(s, 3, 0, 1) -- parted
        local f2 = model.Fragment(s, 1, 2, -1) -- parted
        local block = model.Block({f1, f2})
        local bs = model.BlockSet({s}, {block})
        local HasOverlap = require 'npge.algo.HasOverlap'
        local has, fr1, fr2 = HasOverlap(bs)
        assert.truthy(has)
        assert.equal(fr1:common(fr2), 2)
    end)

    it("tests that blockset contains overlaps (equal frag.)",
    function()
        local model = require 'npge.model'
        local s = model.Sequence("g&c&c", "ATGC")
        local f1 = model.Fragment(s, 0, 0, 1)
        local f2 = model.Fragment(s, 0, 0, 1)
        local block = model.Block({f1, f2})
        local bs = model.BlockSet({s}, {block})
        local HasOverlap = require 'npge.algo.HasOverlap'
        local has, fr1, fr2 = HasOverlap(bs)
        assert.truthy(has)
        assert.equal(fr1:common(fr2), 1)
    end)
end)
