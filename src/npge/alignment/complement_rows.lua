return function(rows)
    local new_rows = {}
    local complement = require 'npge.alignment.complement'
    for i, row in ipairs(rows) do
        table.insert(new_rows, complement(row))
    end
    return new_rows
end
