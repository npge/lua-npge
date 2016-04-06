-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2016 Boris Nagaev
-- See the LICENSE file for terms of use.

local TMP

return function()
    local fname = os.tmpname()
    local f = io.open(fname, 'w')
    if not f then
        -- http://www.luafaq.org/#T1.40
        TMP = TMP or os.getenv("TMP")
        if TMP then
            fname = TMP .. fname
        end
        f = assert(io.open(fname, 'w'))
    end
    f:close()
    return fname
end
