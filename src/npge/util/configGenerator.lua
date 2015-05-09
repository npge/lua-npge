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

return function()
    local config = require 'npge.config'
    local lines = {}
    for section_name, section in pairs(config) do
        for name, value in pairs(section) do
            local about = config.about[section_name][name]
            table.insert(lines, "-- " .. about)
            local line = "%s.%s = %s"
            table.insert(lines, line:format(section_name,
                name, serialize(value)))
            table.insert(lines, "")
        end
    end
    return table.concat(lines, "\n")
end
