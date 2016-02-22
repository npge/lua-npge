-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2016 Boris Nagaev
-- See the LICENSE file for terms of use.

return function(rows)
    local new_rows = {}
    local complement = require 'npge.alignment.complement'
    for _, row in ipairs(rows) do
        table.insert(new_rows, complement(row))
    end
    return new_rows
end
