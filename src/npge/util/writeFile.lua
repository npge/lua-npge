-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2016 Boris Nagaev
-- See the LICENSE file for terms of use.

return function(fname, text)
    local f = io.open(fname, 'w')
    f:write(text)
    f:close()
end
