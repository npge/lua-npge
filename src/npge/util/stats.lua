-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

local function stats(values)
    local min, max, med, avg
    local n = #values
    if n > 0 then
        local sum = 0
        for _, value in ipairs(values) do
            sum = sum + value
            min = min and math.min(min, value) or value
            max = max and math.max(max, value) or value
        end
        table.sort(values)
        local middle = math.floor((n + 1) / 2)
        if n % 2 == 1 then
            med = values[middle]
        else
            med = (values[middle] + values[middle + 1]) / 2.0
        end
        avg = sum / n
    end
    return min, max, med, avg
end

return stats
