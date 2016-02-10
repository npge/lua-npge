-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2016 Boris Nagaev
-- See the LICENSE file for terms of use.

describe("npge.alignment.toAtgcnAndGap", function()
    it("cleans all except ATGCN and gaps", function()
        local f = require 'npge.alignment.toAtgcnAndGap'
        assert.are.equal(f("a T g"), "ATG")
        assert.are.equal(f("a T-g"), "AT-G")
        assert.are.equal(f("a T--\ng"), "AT--G")
        assert.are.equal(f(""), "")
    end)
end)
