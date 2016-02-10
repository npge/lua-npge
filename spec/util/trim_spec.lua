-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2016 Boris Nagaev
-- See the LICENSE file for terms of use.

describe("npge.util.trim", function()
    it("trims a string", function()
        local trim = require 'npge.util.trim'
        assert.equal(trim("asdfg"), "asdfg")
        assert.equal(trim(" asdfg "), "asdfg")
        assert.equal(trim("asdfg "), "asdfg")
        assert.equal(trim(" asdfg"), "asdfg")
        assert.equal(trim(" as  dfg"), "as  dfg")
        assert.equal(trim(" a\ns\tdfg\n\t"), "a\ns\tdfg")
    end)
end)
