describe("util.sandbox", function()
    it("makes sandboxed function", function()
        local sandbox = require 'npge.util.sandbox'
        local env = {}
        local f = sandbox(env, 'print = ... + 1; return print')
        local result = f(2)
        assert.equal(type(print), 'function')
        assert.equal(result, env.print)
        assert.equal(result, 3)
    end)

    it("returns nil if type of code is not string", function()
        local sandbox = require 'npge.util.sandbox'
        local env = {}
        local f = sandbox(env, function(x) return x end)
        assert.falsy(f)
    end)

    it("returns nil if code is a bytecode", function()
        local sandbox = require 'npge.util.sandbox'
        local env = {}
        local f = sandbox(env, string.dump(function() end))
        assert.falsy(f)
    end)

    it("returns nil if the code contains an error", function()
        local sandbox = require 'npge.util.sandbox'
        local env = {}
        local f = sandbox(env, "x = 1; x++") -- Lua is not C
        assert.falsy(f)
    end)
end)
