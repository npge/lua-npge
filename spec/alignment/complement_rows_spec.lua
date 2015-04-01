-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

describe("alignment.complement_rows", function()
    it("calculates complement rows", function()
        local f = require 'npge.alignment.complement_rows'
        assert.same(f({"ATGC"}), {"GCAT"})
        assert.same(f({"ATGC", "AT-C"}), {"GCAT", "G-AT"})
    end)
end)
