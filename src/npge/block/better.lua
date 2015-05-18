-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

local function lengthsSum(block)
    local sum = 0
    for fragment in block:iterFragments() do
        sum = sum + fragment:length()
    end
    return sum
end

return function(block1, block2)
    local s1 = block1:size()
    local s2 = block2:size()
    local l1 = lengthsSum(block1)
    local l2 = lengthsSum(block2)
    return s1 > s2 or (s1 == s2 and l1 > l2)
end
