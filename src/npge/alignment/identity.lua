-- use C version if available
local has_c, cpp = pcall(require, 'npge.cpp')
if has_c then
    return cpp.identity
end

return function(rows, start, stop)
    if #rows == 0 then
        return 0, 0, 0
    end
    local length = #rows[1]
    if length == 0 then
        return 0, 0, 0
    end
    start = start or 0
    stop = stop or length - 1
    assert(start >= 0)
    assert(start <= stop)
    assert(stop <= length - 1)
    for _, row in ipairs(rows) do
        assert(type(row) == 'string')
        assert(#row == length)
    end
    local ident = 0
    for col = start + 1, stop + 1 do
        local gap, first, bad
        for _, row in ipairs(rows) do
            local letter = row:sub(col, col)
            if letter == '-' then
                gap = true
            elseif first and letter ~= first then
                bad = true -- different nongap letters
                break
            else
                first = letter
            end
        end
        if not bad and not gap then
            ident = ident + 1
        elseif not bad and gap then
            ident = ident + 0.5
        end
    end
    local l = stop - start + 1
    return ident / l, ident, l
end
