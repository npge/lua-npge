-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2016 Boris Nagaev
-- See the LICENSE file for terms of use.

return function(str)
    local text = str:gsub("%s+$", "")
    text = text:gsub("^%s+", "")
    return text
end
