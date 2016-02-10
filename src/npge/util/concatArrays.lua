-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2016 Boris Nagaev
-- See the LICENSE file for terms of use.

return function(...)
    local arrays = {...}
    local result = {}
    for _, array in ipairs(arrays) do
        assert(type(array) == 'table')
        for _, item in ipairs(array) do
            table.insert(result, item)
        end
    end
    return result
end
