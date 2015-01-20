return function(blockset)
    local blocks = {}
    for block in blockset:iter_blocks() do
        local orient = require 'npge.block.orient'
        block = orient(block)
        table.insert(blocks, block)
    end
    local BlockSet = require 'npge.model.BlockSet'
    return BlockSet(blockset:sequences(), blocks)
end
