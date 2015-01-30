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
    local aligned_row = table.concat(aligned[1] or {})
    local result = {}
    local tails = {}
    for i, _ in ipairs(aligned) do
        table.insert(result, aligned_row)
        table.insert(tails, rows[i]:sub(pos))
    end
    return result, tails
end
