-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

describe("npge.util.extractValue", function()
    it("extract values from key=value string", function()
        local ev = require 'npge.util.extractValue'
        assert.equal(ev("a=b c=d", "a"), "b")
        assert.equal(ev("abc=123 fre=567", "fre"), "567")
        assert.equal(ev('abc=1 "fre=5 tt=ttt"', "fre"),
            "5 tt=ttt")
    end)
end)
