-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

return function(values, key)
    local value = values:match('"' .. key .. '=(.*)"')
    if not value then
        value = values:match(key .. '=(%w*)')
    end
    return value
end
