-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

describe("npge.util.timer", function()
    it("measures time spent by functions (wrap function)",
    function()
        local f = function(x)
            return x * 10
        end
        assert.equal(f(42), 420)
        local timer = require 'npge.util.timer'
        f = timer.wrapFunction(f)
        assert.equal(f(42), 420)
        assert.equal(type(timer.spentTime(f)), 'number')
        f = timer.unwrapFunction(f)
        assert.equal(f(42), 420)
    end)

    it("measures time spent by functions (module's functions",
    function()
        local f = function(x)
            return x * 10
        end
        local module = {
            f = f,
        }
        assert.equal(module.f(42), 420)
        local timer = require 'npge.util.timer'
        timer.wrapModule(module)
        assert.equal(module.f(42), 420)
        assert.equal(type(timer.spentTime(module.f)), 'number')
        timer.unwrapModule(module)
        assert.equal(module.f(42), 420)
    end)
end)
