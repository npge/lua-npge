-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2016 Boris Nagaev
-- See the LICENSE file for terms of use.

describe("npge.alignment.complementRows", function()
    it("calculates complement rows", function()
        local f = require 'npge.alignment.complementRows'
        assert.same(f({"ATGC"}), {"GCAT"})
        assert.same(f({"ATGC", "AT-C"}), {"GCAT", "G-AT"})
    end)
end)
