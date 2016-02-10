-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2016 Boris Nagaev
-- See the LICENSE file for terms of use.

return function(block)
    local slice = require 'npge.block.slice'
    local hasSelfOverlap = require 'npge.block.hasSelfOverlap'
    if not hasSelfOverlap(block) then
        return {block}
    end
    local function makeSlice(length)
        return slice(block, 0, length - 1)
    end
    local function hasOverlap(length)
        return hasSelfOverlap(makeSlice(length))
    end
    if hasOverlap(1) then
        -- even first column of the block has self-overlap
        return {}
    end
    assert(hasOverlap(block:length()))
    local binary_search = require 'npge.util.binary_search'
    local first_overlap = binary_search.firstTrue(hasOverlap,
        1, block:length())
    assert(first_overlap > 1)
    assert(first_overlap < block:length())
    local new_block = makeSlice(first_overlap - 1)
    assert(not hasSelfOverlap(new_block))
    return {new_block}
end
