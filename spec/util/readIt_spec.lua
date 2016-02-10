-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2016 Boris Nagaev
-- See the LICENSE file for terms of use.

describe("npge.util.readIt", function()
    it("converts iterator to string", function()
        local readIt = require 'npge.util.readIt'
        local wrap, yield = coroutine.wrap, coroutine.yield
        local generator = wrap(function()
            yield('123')
            yield('abc')
        end)
        local str = readIt(generator)
        assert.equal(str, '123abc')
    end)
end)
