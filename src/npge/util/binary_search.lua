-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

local binary_search = {}

-- http://www.cplusplus.com/reference/algorithm/lower_bound/
function binary_search.lower(list, value)
    local first = 1
    local count = #list
    while count > 0 do
        local step = math.floor(count / 2)
        local it = first + step
        if list[it] < value then
            first = it + 1
            count = count - step - 1
        else
            count = step
        end
    end
    return first
end

-- http://www.cplusplus.com/reference/algorithm/upper_bound/
function binary_search.upper(list, value)
    local first = 1
    local count = #list
    while count > 0 do
        local step = math.floor(count / 2)
        local it = first + step
        if not(value < list[it]) then
            first = it + 1
            count = count - step - 1
        else
            count = step
        end
    end
    return first
end

function binary_search.firstTrue(f, min, max)
    local first = min
    local count = max - min + 1
    while count > 0 do
        local step = math.floor(count / 2)
        local it = first + step
        if not f(it) then
            first = it + 1
            count = count - step - 1
        else
            count = step
        end
    end
    return first
end

return binary_search
