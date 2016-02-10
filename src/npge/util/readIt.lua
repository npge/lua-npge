-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2016 Boris Nagaev
-- See the LICENSE file for terms of use.

return function(it)
    local array = {}
    for part in it do
        table.insert(array, part)
    end
    return table.concat(array)
end
