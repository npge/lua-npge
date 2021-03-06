-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2016 Boris Nagaev
-- See the LICENSE file for terms of use.

return function(rowss)
    local size = #rowss[1]
    for _, rows in ipairs(rowss) do
        assert(#rows == size)
        local length = #rows[1]
        for _, row in ipairs(rows) do
            assert(#row == length)
        end
    end
    local result = {}
    for i = 1, size do
        local parts = {}
        for _, rows in ipairs(rowss) do
            table.insert(parts, rows[i])
        end
        table.insert(result, table.concat(parts))
    end
    return result
end
