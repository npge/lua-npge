-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2016 Boris Nagaev
-- See the LICENSE file for terms of use.

return function(cmd)
    if _VERSION == 'Lua 5.1' then
        return os.execute(cmd) == 0
    else
        -- Lua >= 5.2
        return os.execute(cmd)
    end
end
