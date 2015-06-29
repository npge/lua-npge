-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

describe("npge.cpp.alignment.MAX_COLUMN_SCORE", function()
    it("is rqual to 100", function()
        local cpp = require 'npge.cpp'
        assert.equal(cpp.alignment.MAX_COLUMN_SCORE, 100)
    end)
end)
