-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2016 Boris Nagaev
-- See the LICENSE file for terms of use.

describe("npge.util.isWindows", function()
    it("determines is the OS is Windows", function()
        local isWindows = require 'npge.util.isWindows'
        if package.config:sub(1,1) == '\\' then
            assert.truthy(isWindows)
        else
            assert.falsy(isWindows)
        end
    end)
end)
