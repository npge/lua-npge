-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

-- return block type (1 letter), size, length and n (optional)
return function(name)
    local name_re = "^(%a)(%d+)x(%d+)n?(%d*)$"
    local t, size, length, n = name:match(name_re)
    return t, tonumber(size), tonumber(length), tonumber(n)
end
