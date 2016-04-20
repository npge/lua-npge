-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2016 Boris Nagaev
-- See the LICENSE file for terms of use.

describe("npge.algo.SubBlockSet", function()
    it("create a subset of fragments located on particular sequences",
    function()
        local model = require 'npge.model'
        local s1 = model.Sequence("s1", "A-AT")
        local s2 = model.Sequence("s2", "A-AT")
        local s3 = model.Sequence("s3", "ATAT")
        local f1 = model.Fragment(s1, 0, s1:length() - 1, 1)
        local f2 = model.Fragment(s2, 0, s2:length() - 1, 1)
        local f3 = model.Fragment(s3, 0, s3:length() - 1, 1)
        local b = model.Block({
            {f1, "A-AT"},
            {f2, "A-AT"},
            {f3, "ATAT"},
        })
        local bs = model.BlockSet({s1, s2, s3}, {b})
        --
        local SubBlockSet = require 'npge.algo.SubBlockSet'
        assert.equal(SubBlockSet(bs, {s1}), model.BlockSet({s1}, {
            model.Block({
                {f1, "AAT"},
            }),
        }))
        assert.equal(SubBlockSet(bs, {s1, s2}), model.BlockSet({s1, s2}, {
            model.Block({
                {f1, "AAT"},
                {f2, "AAT"},
            }),
        }))
        assert.equal(SubBlockSet(bs, {s1, s2, s3}), bs)
    end)
end)
