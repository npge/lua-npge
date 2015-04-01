-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

describe("alignment.to_atgcn", function()
    it("converts to atgcn", function()
        local to_atgcn = require 'npge.alignment.to_atgcn'
        assert.are.equal(to_atgcn("a T g"), "ATG")
        assert.are.equal(to_atgcn(""), "")
    end)
end)
