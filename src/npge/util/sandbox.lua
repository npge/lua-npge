-- based on http://stackoverflow.com/a/6982080

-- takes code of Lua function
-- return the function sandboxed using environment env

return function(env, code)
    assert(type(env) == 'table')
    if type(code) ~= 'string' then
        return nil, 'Type of code should be string'
    end
    if code:byte(1) == 27 then
        return nil, 'Bytecode is not allowed'
    end
    assert(_VERSION == 'Lua 5.2' or _VERSION == 'Lua 5.1',
        'Implemented in Lua 5.1 and 5.2 only')
    if _VERSION == 'Lua 5.2' or _VERSION == 'Lua 5.3' then
        return load(code, 'sandbox', 't', env)
    elseif _VERSION == 'Lua 5.1' then
        local f, message = loadstring(code, 'sandbox')
        if not f then
            return nil, message
        end
        setfenv(f, env)
        return f
    end
end
