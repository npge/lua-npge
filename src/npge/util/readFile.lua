-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2016 Boris Nagaev
-- See the LICENSE file for terms of use.

return function(fname)
    local f = io.open(fname, "rb")
    local content = f:read("*a")
    f:close()
    return content
end
