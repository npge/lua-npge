-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2016 Boris Nagaev
-- See the LICENSE file for terms of use.

describe("npge.util.popen", function()
    it("reads from a subprocess", function()
        local popen = require 'npge.util.popen'
        local f = popen('dir', 'r')
        assert.truthy(f:read('*a'))
        f:close()
    end)
end)
