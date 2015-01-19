return function(...)
    local rowss = {...}
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
