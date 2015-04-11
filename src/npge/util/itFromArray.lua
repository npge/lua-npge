-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

return function(array)
    local it, t, index = ipairs(array)
    local value
    return function()
        index, value = it(t, index)
        return value
    end
end
