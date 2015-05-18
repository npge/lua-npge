-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

return function(blockset, max_length)
    if not max_length then
        max_length = require 'npge.config'.general.MIN_LENGTH
    end
    local new_blocks = {}
    local extend = require 'npge.block.extend'
    for block in blockset:iterBlocks() do
        local b = assert(extend(block, max_length))
        table.insert(new_blocks, b)
    end
    local BlockSet = require 'npge.model.BlockSet'
    return BlockSet(blockset:sequences(), new_blocks)
end
