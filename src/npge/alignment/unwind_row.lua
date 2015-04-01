-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

-- use C version if available
local has_c, cpp = pcall(require, 'npge.cpp')
if has_c then
    return cpp.func.unwindRow
end

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
