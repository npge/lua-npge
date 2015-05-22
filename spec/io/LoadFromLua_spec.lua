-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

describe("npge.io.LoadFromLua", function()
    it("loads Lua files in #sandbox", function()
        local model = require 'npge.model'
        local s = model.Sequence("test_name", "ATAT")
        local f1 = model.Fragment(s, 0, 1, 1)
        local f2 = model.Fragment(s, 3, 2, -1)
        local block1 = model.Block({f2})
        local block2 = model.Block({f1})
        local blockset = model.BlockSet({s}, {block1, block2})
        local BlockSetToLua = require 'npge.io.BlockSetToLua'
        local readIt = require 'npge.util.readIt'
        local lua = readIt(BlockSetToLua(blockset))
        local LoadFromLua = require 'npge.io.LoadFromLua'
        local blockset1 = LoadFromLua(lua)()
        assert.equal(blockset1, blockset)
    end)

    it("is protected from a crash", function()
        local lua = [[
        local model = require 'npge.model'
        local s = model.Sequence("test_name", "ATAT")
        s.__gc(s)
        local n = s:name()
        ]]
        local LoadFromLua = require 'npge.io.LoadFromLua'
        assert.has_error(function()
            local blockset1 = LoadFromLua(lua)()
        end)
    end)

    it("can't change metatables of our classes", function()
        local lua = [[
        local model = require 'npge.model'
        local s = model.Sequence("test_name", "ATAT")
        s.__index.name = function() return 'hack' end
        return s
        ]]
        local LoadFromLua = require 'npge.io.LoadFromLua'
        assert.has_error(function()
            local blockset1 = LoadFromLua(lua)()
        end)
        local model = require 'npge.model'
        local s = model.Sequence("test_name", "ATAT")
        assert.not_equal(s:name(), 'hack')
    end)

    it("loads sequences + blockset", function()
        local model = require 'npge.model'
        local s = model.Sequence("test_name", "ATAT")
        local f1 = model.Fragment(s, 0, 1, 1)
        local f2 = model.Fragment(s, 3, 2, -1)
        local block1 = model.Block({f2})
        local block2 = model.Block({f1})
        local blockset = model.BlockSet({s},
            {block1, block2})
        local seqs_bs = model.BlockSet({s}, {})
        local readIt = require 'npge.util.readIt'
        local BlockSetToLua = require 'npge.io.BlockSetToLua'
        local lua = readIt(BlockSetToLua(blockset))
        local LoadFromLua = require 'npge.io.LoadFromLua'
        local blockset1 = LoadFromLua(lua)(seqs_bs)
        assert.equal(blockset1, blockset)
    end)

    it("loads from reference to blockset", function()
        local BlockSet = require 'npge.model.BlockSet'
        if BlockSet.toRef and BlockSet.fromRef then
            local model = require 'npge.model'
            local s = model.Sequence("test_name", "ATAT")
            local f1 = model.Fragment(s, 0, 1, 1)
            local block1 = model.Block({f1})
            local blockset = BlockSet({s}, {block1})
            local lua = [[do
                local BlockSet = require 'npge.model.BlockSet'
                return BlockSet.fromRef(%q)
            end ]]
            lua = lua:format(BlockSet.toRef(blockset))
            local LoadFromLua = require 'npge.io.LoadFromLua'
            local enableRefs = true
            local blockset1 = LoadFromLua(lua, enableRefs)()
            assert.equal(blockset1, blockset)
        end
    end)
end)
