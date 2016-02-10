-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2016 Boris Nagaev
-- See the LICENSE file for terms of use.

return function(blockset)
    local excludeSelfOverlap =
        require 'npge.block.excludeSelfOverlap'
    local blocks = {}
    for block in blockset:iterBlocks() do
        local new_blocks = excludeSelfOverlap(block)
        for _, block1 in ipairs(new_blocks) do
            table.insert(blocks, block1)
        end
    end
    local BlockSet = require 'npge.model.BlockSet'
    local result = BlockSet(blockset:sequences(), blocks)
    local HasSelfOverlap = require 'npge.algo.HasSelfOverlap'
    assert(not HasSelfOverlap(result))
    return result
end
