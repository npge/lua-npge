-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

return function(blockset, lengthsGetter)
    local extend = require 'npge.block.extend'
    local BlockSet = require 'npge.model.BlockSet'
    local new_blocks = {}
    for block in blockset:iterBlocks() do
        local left_length, right_length = lengthsGetter(block)
        block = extend(block, left_length, right_length)
        table.insert(new_blocks, block)
    end
    return BlockSet(blockset:sequences(), new_blocks)
end
