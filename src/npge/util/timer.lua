-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2016 Boris Nagaev
-- See the LICENSE file for terms of use.

local timer = {}

local TIME = {}
local ORIGINAL = {}

timer.wrapFunction = function(f)
    local user = 0
    local real = 0
    return function(...)
        local args = {...}
        if args[1] == TIME then
            return user, real
        elseif args[1] == ORIGINAL then
            return f
        else
            local t1 = os.clock()
            local t1a = os.time()
            local results = {f(...)}
            local t2 = os.clock()
            local t2a = os.time()
            user = user + (t2 - t1)
            real = real + os.difftime(t2a, t1a)
            local unpack = require 'npge.util.unpack'
            return unpack(results)
        end
    end
end

timer.unwrapFunction = function(f)
    return f(ORIGINAL)
end

timer.spentTime = function(f)
    return f(TIME)
end

timer.wrapModule = function(namespace)
    -- replaces all functions in namespace
    -- with time-counting wrappers
    local copy = {}
    for k, v in pairs(namespace) do
        copy[k] = v
    end
    for k, v in pairs(copy) do
        if type(v) == 'function' then
            namespace[k] = timer.wrapFunction(v)
        end
    end
end

timer.unwrapModule = function(namespace)
    -- reverts timer.wrap
    local copy = {}
    for k, v in pairs(namespace) do
        copy[k] = v
    end
    for k, v in pairs(copy) do
        if type(v) == 'function' then
            namespace[k] = v(ORIGINAL)
        end
    end
end

return timer
