-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

describe("npge.util.nullName", function()
    it("returns name of NULL device", function()
        local nullName = require 'npge.util.nullName'
        local name = nullName()
        assert.equal(type(name), 'string')
        assert.truthy(#name > 0)
    end)
end)
