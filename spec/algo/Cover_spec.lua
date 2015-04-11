-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

describe("npge.algo.Cover", function()
    it("covers noncovered parts of sequence (none)", function()
        local model = require 'npge.model'
        local s = model.Sequence("s", "ATAT")
        local f1 = model.Fragment(s, 0, 0, 1)
        local f2 = model.Fragment(s, 2, 3, 1)
        local b = model.Block({f1, f2})
        local blockset = model.BlockSet({s}, {b})
        local Cover = require 'npge.algo.Cover'
        local covered = Cover(blockset)
        assert.equal(covered, model.BlockSet({s}, {b,
            model.Block({model.Fragment(s, 1, 1, 1)})}))
    end)
end)
