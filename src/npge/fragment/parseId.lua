-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

return function(id)
    local seqname, start, stop, ori =
        id:match("^(%S+)_(%d+)_(%d+)_(-?1)$")
    if not seqname then
        -- old format
        seqname, start, stop =
            id:match("^(%S+)_(%d+)_(-?%d+)$")
        ori = (start <= stop) and 1 or -1
        if stop == '-1' then
            -- special case for reverse fragment of length 1
            stop = start
            ori = -1
        end
    end
    start = assert(tonumber(start))
    stop = assert(tonumber(stop))
    ori = assert(tonumber(ori))
    return seqname, start, stop, ori
end
