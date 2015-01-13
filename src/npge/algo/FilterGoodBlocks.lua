return function(blockset)
    local is_good = require 'npge.block.is_good'
    local blocks = {}
    for block in blockset:iter_blocks() do
        if is_good(block) then
            table.insert(blocks, block)
        end
    end
    local BlockSet = require 'npge.model.BlockSet'
    return BlockSet(blockset:sequences(), blocks)
end
