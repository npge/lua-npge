-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

return function(id)
    local seqname, start, stop, ori =
        id:match("^([^%s_]+)_(%d+)_(%d+)_(-?1)$")
    if not seqname then
        -- old format
        -- single line to satisfy luacov
        -- https://github.com/keplerproject/luacov/issues/33
        seqname, start, stop = id:match("^([^%s_]+)_(%d+)_(-?%d+)$")
        start = tonumber(start)
        stop = tonumber(stop)
        if not start or not stop then
            return nil
        end
        ori = (start <= stop) and 1 or -1
        if stop == -1 then
            -- special case for reverse fragment of length 1
            stop = start
            ori = -1
        end
    else
        start = tonumber(start)
        stop = tonumber(stop)
        ori = tonumber(ori)
    end
    return seqname, start, stop, ori
end
