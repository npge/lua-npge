-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

local TMP

return function()
    local fname = os.tmpname()
    local fileExists = require 'npge.util.fileExists'
    if not fileExists(fname) then
        -- http://www.luafaq.org/#T1.40
        TMP = TMP or os.getenv("TMP")
        if TMP then
            fname = TMP .. fname
        end
    end
    return fname
end
