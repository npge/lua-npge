-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

-- hits must be a hit returned bu BlastHit
return function(hit)
    assert(hit:size() == 2)
    local fragments = hit:fragments()
    local f1 = fragments[1]
    local f2 = fragments[2]
    local format = "(%s, %s)"
    return format:format(f1:id(), f2:id())
end
