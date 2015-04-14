-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

return function(block)
    local slice = require 'npge.block.slice'
    local hasSelfOverlap = require 'npge.block.hasSelfOverlap'
    if not hasSelfOverlap(block) then
        return {block}
    end
    local function isGood(length)
        return hasSelfOverlap(slice(block, 1, length))
    end
    if not isGood(1) then
        -- even first column of the block has self-overlap
        return {}
    end
    local min = 1
    local max = block:length()
    -- binary search
    while min < max do
        local middle = math.floor((min + 1 + max) / 2)
        if isGood(middle) then
            min = middle
        else
            max = middle
        end
    end
    assert(min == max)
    assert(1 < min)
    assert(max < block:length())
    return {slice(block, 1, min)}
end
