-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2016 Boris Nagaev
-- See the LICENSE file for terms of use.

return function(chunks)
    -- chunks is iterator (like file:lines())
    local split = require 'npge.util.split'
    local trim = require 'npge.util.trim'
    return coroutine.wrap(function()
        local name, description, text_lines
        local function yield()
            if name then
                -- add sequence
                local text = table.concat(text_lines)
                coroutine.yield(name, description, text)
                name = nil
                description = nil
                text_lines = nil
            end
        end
        for chunk in chunks do
            for line in chunk:gmatch("([^\r\n]+)") do
                line = trim(line)
                if line:sub(1, 1) == '>' then
                    yield()
                    local header = trim(line:sub(2, -1))
                    local fields = split(header, '%s+', 1)
                    name = fields[1]
                    description = fields[2] or ''
                    text_lines = {}
                elseif #line > 0 then
                    assert(name)
                    table.insert(text_lines, line)
                end
            end
        end
        -- add last sequence
        yield()
    end)
end
