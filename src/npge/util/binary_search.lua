-- http://www.cplusplus.com/reference/algorithm/lower_bound/
local lower = function(list, value)
    local math = require 'math'
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
local upper = function(list, value)
    local math = require 'math'
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

return {
    lower = lower,
    upper = upper,
}
