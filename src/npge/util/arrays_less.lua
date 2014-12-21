return function(a, b)
    assert(#a == #b)
    local n = #a
    for i = 1, n do
        if a[i] < b[i] then
            return true
        elseif a[i] > b[i] then
            return false
        end
    end
    return false
end
