-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

describe("npge.util.toFasta", function()
    it("makes fasta representation", function()
        local toFasta = require 'npge.util.toFasta'
        local fasta = toFasta("foo", "bar", "ATGC")
        assert.truthy(fasta:match(">foo bar"))
        assert.truthy(fasta:match("ATGC"))
    end)
end)
