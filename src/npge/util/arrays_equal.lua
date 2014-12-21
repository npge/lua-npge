return function(a, b)
    if #a ~= #b then
        return false
    end
    local n = #a
    for i = 1, n do
        if a[i] ~= b[i] then
            return false
        end
    end
    return true
end
