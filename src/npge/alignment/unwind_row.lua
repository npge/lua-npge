return function(row, orig_row)
    local new_row = {}
    local orig_i = 1
    for i = 1, #row do
        local c = row:sub(i, i)
        if c == '-' then
            table.insert(new_row, '-')
        else
            table.insert(new_row, orig_row:sub(orig_i, orig_i))
            orig_i = orig_i + 1
        end
    end
    assert(orig_i == #orig_row + 1)
    return table.concat(new_row)
end
