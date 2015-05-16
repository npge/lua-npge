-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

local NULL

return function()
    if NULL then
        return NULL
    end
    local fileExists = require 'npge.util.fileExists'
    if fileExists('/dev/null') then
        NULL = '/dev/null'
    else
        -- Windows
        NULL = 'NUL'
    end
    return NULL
end
