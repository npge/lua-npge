-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2016 Boris Nagaev
-- See the LICENSE file for terms of use.

return function(text)
    local result = {}
    local step = 50
    for i = 1, #text, step do
        table.insert(result, text:sub(i, i + step - 1))
    end
    return table.concat(result, "\n")
end
