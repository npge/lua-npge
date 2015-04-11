-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

describe("npge.alignment.toAtgcn", function()
    it("converts to atgcn", function()
        local toAtgcn = require 'npge.alignment.toAtgcn'
        assert.are.equal(toAtgcn("a T g"), "ATG")
        assert.are.equal(toAtgcn(""), "")
    end)
end)
