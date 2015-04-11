-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

return function(blockset)
    local blocks = {}
    for block in blockset:iterBlocks() do
        local orient = require 'npge.block.orient'
        block = orient(block)
        table.insert(blocks, block)
    end
    local BlockSet = require 'npge.model.BlockSet'
    return BlockSet(blockset:sequences(), blocks)
end
