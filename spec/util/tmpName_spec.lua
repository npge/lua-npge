-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

describe("npge.util.tmpName", function()
    it("returns name of NULL device", function()
        local fileExists = require 'npge.util.fileExists'
        local tmpName = require 'npge.util.tmpName'
        local name = tmpName()
        assert.truthy(fileExists(name))
        os.remove(name)
    end)
end)
