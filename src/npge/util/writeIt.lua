-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

return function(fname, it)
    local f = io.open(fname, 'w')
    for text in it do
        f:write(text)
    end
    f:close()
end
