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

