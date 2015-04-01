-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

return function(array)
    local set = {}
    local result = {}
    for _, item in ipairs(array) do
        if not set[item] then
            table.insert(result, item)
            set[item] = true
        end
    end
    return result
end
