-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2016 Boris Nagaev
-- See the LICENSE file for terms of use.

describe("npge.util.configGenerator", function()
    it("generates config file npge.conf", function()
        local npge = require 'npge'
        local conf = npge.util.configGenerator()
        assert.truthy(conf:match("MIN_LENGTH"))
    end)

    it("generates config file npge.conf in MarkDown format",
    function()
        local npge = require 'npge'
        local conf = npge.util.configGenerator{markdown=true}
        assert.truthy(conf:match(" %* "))
    end)
end)
