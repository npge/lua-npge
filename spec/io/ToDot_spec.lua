-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2016 Boris Nagaev
-- See the LICENSE file for terms of use.

local model = require 'npge.model'

describe("npge.io.ToDot", function()
    it("exports a blockset as a graph (DOT)", function()
        local bs = dofile('spec/sample_pangenome3.lua')
        local ToDot = require 'npge.io.ToDot'
        local dot = ToDot(bs)
        assert.truthy(dot:match('s3x1627'))
    end)
end)
