-- http://rosettacode.org/wiki/Binary_search#Lua
return function(list, value)
    local math = require 'math'
    local low = 1
    local high = #list
    local mid = 0
    while low <= high do
        mid = math.floor((low + high) / 2)
        if list[mid] > value then
            high = mid - 1
        elseif list[mid] < value then
            low = mid + 1
        else
            return mid
        end
    end
end

