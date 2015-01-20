return function(blockset)
    local blocks = {}
    for block in blockset:iter_blocks() do
        local align = require 'npge.block.align'
        block = align(block)
        table.insert(blocks, block)
    end
    local BlockSet = require 'npge.model.BlockSet'
    return BlockSet(blockset:sequences(), blocks)
end
