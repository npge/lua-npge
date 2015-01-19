return function(rows)
    -- Input:
    --     ......
    --     .....
    --     .......
    -- Output:
    --     ***   ....
    --     *** , ..
    --     ***   ....
    local aligned = {}
    for _, row in ipairs(rows) do
        -- list of char's
        table.insert(aligned, {})
        assert(#row >= 1)
    end
    local pos = 1
    while true do
        local first = rows[1]:sub(pos, pos)
        if #first == 0 then
            break
        end
        local bad
        for _, row in ipairs(rows) do
            local letter = row:sub(pos, pos)
            if letter ~= first then
                bad = true
            end
        end
        if bad then
            break
        end
        for _, aligned_row in ipairs(aligned) do
            table.insert(aligned_row, first)
        end
        pos = pos + 1
    end
    local result = {}
    local tails = {}
    for i, aligned_row in ipairs(aligned) do
        table.insert(result, table.concat(aligned_row))
        table.insert(tails, rows[i]:sub(pos))
    end
    return result, tails
end
