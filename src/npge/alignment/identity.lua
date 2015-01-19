-- use C version if available
local has_c, cidentity = pcall(require,
    'npge.alignment.cidentity')

return function(rows)
    local length = #rows[1]
    for _, row in ipairs(rows) do
        assert(type(row) == 'string')
        assert(#row == length)
    end
    if has_c then
        return cidentity(rows, #rows, length)
    else
        local ident = 0
        for col = 1, length do
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
        return ident / length
    end
end
