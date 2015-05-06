-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

-- short form = consensuses + mutations
-- short form is sufficient to recover full form

describe("npge.algo.ShortForm", function()
    it("makes short form of a partition", function()
        local ShortForm = require 'npge.algo.ShortForm'
        local npge = require 'npge'
        local s = npge.model.Sequence("s1&c&c", "ATGATGATG")
        local f1 = npge.model.Fragment(s, 2, 4, 1)
        local f2 = npge.model.Fragment(s, 5, 6, 1)
        local f3 = npge.model.Fragment(s, 1, 7, -1)
        local block = npge.model.Block({f1, f2, f3})
        local bs = npge.model.BlockSet({s}, {block})
        local bs1 = ShortForm.decode(ShortForm.encode(bs))
        assert.equal(bs1, bs)
    end)

    it("iterator provides strings", function()
        local ShortForm = require 'npge.algo.ShortForm'
        local npge = require 'npge'
        local s = npge.model.Sequence("s1&c&c", "ATGATGATG")
        local f1 = npge.model.Fragment(s, 2, 4, 1)
        local f2 = npge.model.Fragment(s, 5, 6, 1)
        local f3 = npge.model.Fragment(s, 1, 7, -1)
        local block = npge.model.Block({f1, f2, f3})
        local bs = npge.model.BlockSet({s}, {block})
        local line1 = ShortForm.encode(bs)()
        assert.equal(type(line1), "string")
    end)

    it("raw Lua code is loadable", function()
        local ShortForm = require 'npge.algo.ShortForm'
        local npge = require 'npge'
        local s = npge.model.Sequence("s1&c&c", "ATGATGATG")
        local f1 = npge.model.Fragment(s, 2, 4, 1)
        local f2 = npge.model.Fragment(s, 5, 6, 1)
        local f3 = npge.model.Fragment(s, 1, 7, -1)
        local block = npge.model.Block({f1, f2, f3})
        local bs = npge.model.BlockSet({s}, {block})
        local readIt = require 'npge.util.readIt'
        local lua = readIt(ShortForm.encode(bs))
        local loadstring = require 'npge.util.loadstring'
        local bs1 = loadstring(lua)()
        assert.equal(bs1, bs)
    end)

    it("makes short form of the sample pangenome", function()
        local ShortForm = require 'npge.algo.ShortForm'
        local readFile = require 'npge.util.readFile'
        local LoadFromLua = require 'npge.algo.LoadFromLua'
        local sample = readFile('spec/sample_pangenome.lua')
        local bs = LoadFromLua(sample)()
        local bs1 = ShortForm.decode(ShortForm.encode(bs))
        assert.equal(bs1, bs)
    end)
end)
