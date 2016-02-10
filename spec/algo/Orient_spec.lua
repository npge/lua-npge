-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2016 Boris Nagaev
-- See the LICENSE file for terms of use.

describe("npge.algo.Orient", function()
    it("orients blocks (1 fragment, ori = -1)",
    function()
        local model = require 'npge.model'
        local s = model.Sequence("test_name", "AATAT")
        local block = model.Block({
            model.Fragment(s, 2, 0, -1),
        })
        local blockset = model.BlockSet({s}, {block})
        local Orient = require 'npge.algo.Orient'
        local reverse = require 'npge.block.reverse'
        assert.equal(Orient(blockset),
            model.BlockSet({s}, {reverse(block)}))
    end)
end)
