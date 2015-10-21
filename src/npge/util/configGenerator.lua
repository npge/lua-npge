-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

local function serialize(value)
    local format
    if type(value) == "number" or type(value) == "boolean"then
        value = tostring(value)
        format = "%s"
    -- elseif type(value) == "string" then
    --     format = "%q"
    end
    return format:format(value)
end

local function sorted(dict)
    return coroutine.wrap(function()
        local keys = {}
        for key, _ in pairs(dict) do
            table.insert(keys, key)
        end
        table.sort(keys)
        for _, key in ipairs(keys) do
            coroutine.yield(key, dict[key])
        end
    end)
end

return function(options)
    options = options or {}
    local markdown = options.markdown
    local lines = {}
    local function print(text)
        table.insert(lines, text)
    end
    local config = require 'npge.config'
    for section_name, section in sorted(config) do
        if markdown then
            print(("  * `%s`"):format(section_name))
        end
        for name, value in sorted(section) do
            local about = config.about[section_name][name]
            if markdown then
                local line = "    * `%s.%s = %s` -- %s"
                print(line:format(section_name, name,
                      serialize(value), about))
            else
                print("-- " .. about)
                local line = "%s.%s = %s"
                print(line:format(section_name,
                    name, serialize(value)))
                print("")
            end
        end
    end
    return table.concat(lines, "\n")
end
