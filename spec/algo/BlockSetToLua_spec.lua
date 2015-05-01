-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

describe("npge.algo.BlockSetToLua", function()
    it("serializes blocksets", function()
        local model = require 'npge.model'
        local B = function(...)
            return model.Block({...})
        end
        local BS = model.BlockSet
        local s1 = model.Sequence("g1&c&c", "ATAT")
        local s2 = model.Sequence("g2&c&c", "ATAT")
        local f1 = model.Fragment(s1, 0, 0, 1)
        local f1a = model.Fragment(s1, 1, 1, 1)
        local f2 = model.Fragment(s2, 0, 0, 1)
        local bs1 = BS({s1, s2}, {B(f1, f2), B(f1a)})
        local BlockSetToLua = require 'npge.algo.BlockSetToLua'
        local readIt = require 'npge.util.readIt'
        local lua = readIt(BlockSetToLua(bs1))
        local loadstring = require 'npge.util.loadstring'
        local bs2 = loadstring(lua)()
        assert.equal(bs1, bs2)
    end)

    it("serializes blocksets (named blocks)", function()
        local model = require 'npge.model'
        local B = function(...)
            return model.Block({...})
        end
        local BS = model.BlockSet
        local s1 = model.Sequence("g1&c&c", "ATAT")
        local s2 = model.Sequence("g2&c&c", "ATAT")
        local f1 = model.Fragment(s1, 0, 0, 1)
        local f1a = model.Fragment(s1, 1, 1, 1)
        local f2 = model.Fragment(s2, 0, 0, 1)
        local bs1 = BS({s1, s2}, {x = B(f1, f2), y = B(f1a)})
        local BlockSetToLua = require 'npge.algo.BlockSetToLua'
        local readIt = require 'npge.util.readIt'
        local lua = readIt(BlockSetToLua(bs1))
        local loadstring = require 'npge.util.loadstring'
        local bs2 = loadstring(lua)()
        assert.equal(bs1, bs2)
        assert.equal(bs2:blockByName("x"), B(f1, f2))
        assert.equal(bs2:blockByName("y"), B(f1a))
    end)

    it("serializes blocksets (fragment length 60)", function()
        local model = require 'npge.model'
        local B = function(...)
            return model.Block({...})
        end
        local BS = model.BlockSet
        local s = model.Sequence("g1&c&c", string.rep("A", 60))
        local f = model.Fragment(s, 0, 0, 1)
        local bs1 = BS({s}, {B(f)})
        local BlockSetToLua = require 'npge.algo.BlockSetToLua'
        local readIt = require 'npge.util.readIt'
        local lua = readIt(BlockSetToLua(bs1))
        local loadstring = require 'npge.util.loadstring'
        local bs2 = loadstring(lua)()
        assert.equal(bs1, bs2)
    end)

    it("serializes blockset without sequences", function()
        local model = require 'npge.model'
        local B = function(...)
            return model.Block({...})
        end
        local BS = model.BlockSet
        local s = model.Sequence("g1&c&c", string.rep("A", 60))
        local f = model.Fragment(s, 0, 0, 1)
        local bs1 = BS({s}, {B(f)})
        local BlockSetToLua = require 'npge.algo.BlockSetToLua'
        local readIt = require 'npge.util.readIt'
        local has_sequences = true
        local lua = readIt(BlockSetToLua(bs1, true))
        local seqs_bs = BS({s}, {})
        local loadstring = require 'npge.util.loadstring'
        local bs2 = loadstring(lua)(seqs_bs)
        assert.equal(bs1, bs2)
    end)
end)
