-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2016 Boris Nagaev
-- See the LICENSE file for terms of use.

describe("npge.alignment.complement", function()
    it("calculates complement sequence", function()
        local complement = require 'npge.alignment.complement'
        assert.are.equal(complement("ATGC"), "GCAT")
        assert.are.equal(complement(""), "")
    end)
end)
