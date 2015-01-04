return function(array)
    local it, t, index = ipairs(array)
    local value
    return function()
        index, value = it(t, index)
        return value
    end
end
