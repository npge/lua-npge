-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

return function(id)
    local seqname, start, stop, ori =
        assert(id:match("(%S+)_(%d+)_(%d+)_(-?1)$"))
    start = tonumber(start)
    stop = tonumber(stop)
    ori = tonumber(ori)
    return seqname, start, stop, ori
end
