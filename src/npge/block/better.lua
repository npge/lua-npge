-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

return function(block1, block2)
    local s1 = block1:size()
    local s2 = block2:size()
    local l1 = block1:length()
    local l2 = block2:length()
    return s1 > s2 or (s1 == s2 and l1 > l2)
end
