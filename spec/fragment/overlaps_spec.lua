-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2016 Boris Nagaev
-- See the LICENSE file for terms of use.

describe("npge.fragment.overlaps", function()

    local model = require 'npge.model'
    local s = model.Sequence("genome&chromosome&c", "ATGC")
    local Fragment = model.Fragment
    local overlaps = require 'npge.fragment.overlaps'

    it("non-parted vs non-parted, same ori", function()
        assert.same(
            overlaps(
                Fragment(s, 0, 0, 1),
                Fragment(s, 0, 0, 1)
            ), {
                Fragment(s, 0, 0, 1),
            }
        )
        assert.same(
            overlaps(
                Fragment(s, 0, 1, 1),
                Fragment(s, 1, 2, 1)
            ), {
                Fragment(s, 1, 1, 1),
            }
        )
        assert.same(
            overlaps(
                Fragment(s, 0, 0, 1),
                Fragment(s, 1, 1, 1)
            ), {
            }
        )
    end)

    it("non-parted vs non-parted, different ori", function()
        assert.same(
            overlaps(
                Fragment(s, 0, 0, 1),
                Fragment(s, 0, 0, -1)
            ), {
                Fragment(s, 0, 0, 1),
            }
        )
        assert.same(
            overlaps(
                Fragment(s, 0, 0, -1),
                Fragment(s, 0, 0, 1)
            ), {
                Fragment(s, 0, 0, -1),
            }
        )
        assert.same(
            overlaps(
                Fragment(s, 0, 1, 1),
                Fragment(s, 2, 1, -1)
            ), {
                Fragment(s, 1, 1, 1),
            }
        )
        assert.same(
            overlaps(
                Fragment(s, 0, 1, 1),
                Fragment(s, 2, 2, -1)
            ), {
            }
        )
    end)

    it("non-parted vs parted, same ori", function()
        assert.same(
            overlaps(
                Fragment(s, 0, 0, 1),
                Fragment(s, 3, 0, 1)
            ), {
                Fragment(s, 0, 0, 1),
            }
        )
        assert.same(
            overlaps(
                Fragment(s, 0, 3, 1),
                Fragment(s, 2, 1, 1)
            ), {
                Fragment(s, 0, 1, 1),
                Fragment(s, 2, 3, 1),
            }
        )
        assert.same(
            overlaps(
                Fragment(s, 1, 2, 1),
                Fragment(s, 2, 1, 1)
            ), {
                Fragment(s, 1, 1, 1),
                Fragment(s, 2, 2, 1),
            }
        )
        assert.same(
            overlaps(
                Fragment(s, 1, 2, 1),
                Fragment(s, 3, 0, 1)
            ), {
            }
        )
    end)

    it("non-parted vs parted, different ori", function()
        assert.same(
            overlaps(
                Fragment(s, 0, 0, 1),
                Fragment(s, 0, 3, -1)
            ), {
                Fragment(s, 0, 0, 1),
            }
        )
        assert.same(
            overlaps(
                Fragment(s, 0, 3, 1),
                Fragment(s, 1, 2, -1)
            ), {
                Fragment(s, 0, 1, 1),
                Fragment(s, 2, 3, 1),
            }
        )
        assert.same(
            overlaps(
                Fragment(s, 1, 2, 1),
                Fragment(s, 1, 2, -1)
            ), {
                Fragment(s, 1, 1, 1),
                Fragment(s, 2, 2, 1),
            }
        )
        assert.same(
            overlaps(
                Fragment(s, 1, 2, 1),
                Fragment(s, 0, 3, -1)
            ), {
            }
        )
    end)

    it("parted vs parted, same ori", function()
        assert.same(
            overlaps(
                Fragment(s, 2, 1, 1),
                Fragment(s, 3, 0, 1)
            ), {
                Fragment(s, 3, 0, 1),
            }
        )
        assert.same(
            overlaps(
                Fragment(s, 3, 0, 1),
                Fragment(s, 2, 1, 1)
            ), {
                Fragment(s, 3, 0, 1),
            }
        )
        assert.same(
            overlaps(
                Fragment(s, 2, 1, 1),
                Fragment(s, 3, 2, 1)
            ), {
                Fragment(s, 2, 2, 1),
                Fragment(s, 3, 1, 1),
            }
        )
    end)

    it("parted vs parted, different ori", function()
        assert.same(
            overlaps(
                Fragment(s, 2, 1, 1),
                Fragment(s, 0, 3, -1)
            ), {
                Fragment(s, 3, 0, 1),
            }
        )
        assert.same(
            overlaps(
                Fragment(s, 3, 0, 1),
                Fragment(s, 1, 2, -1)
            ), {
                Fragment(s, 3, 0, 1),
            }
        )
        assert.same(
            overlaps(
                Fragment(s, 1, 2, -1),
                Fragment(s, 3, 2, 1)
            ), {
                Fragment(s, 1, 3, -1),
                Fragment(s, 2, 2, -1),
            }
        )
    end)

    it("another sequence", function()
        local s2 = model.Sequence("genome2&chromosome&c", "AAAA")
        assert.same(
            overlaps(
                Fragment(s, 0, 0, 1),
                Fragment(s2, 0, 0, 1)
            ), {
            }
        )
    end)

end)
