local TIME = {}
local ORIGINAL = {}

local wrap = function(name, f)
    local time_spent = 0
    return function(...)
        local args = {...}
        if args[1] == TIME then
            return time_spent
        elseif args[1] == ORIGINAL then
            return f
        else
            local t1 = os.clock()
            local results = {f(...)}
            local t2 = os.clock()
            time_spent = time_spent + (t2 - t1)
            local unpack = require 'npge.util.unpack'
            return unpack(results)
        end
    end
end

local timer = {}

timer.wrap = function(namespace)
    -- replaces all functions in namespace
    -- with time-counting wrappers
    local copy = {}
    for k, v in pairs(namespace) do
        copy[k] = v
    end
    for k, v in pairs(copy) do
        if type(v) == 'function' then
            namespace[k] = wrap(k, v)
        end
    end
end

timer.spentTime = function(namespace)
    -- returns table {'name': time_spent}
    local result = {}
    for k, v in pairs(namespace) do
        if type(v) == 'function' then
            result[k] = v(TIME)
        end
    end
    return result
end

timer.unwrap = function(namespace)
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
