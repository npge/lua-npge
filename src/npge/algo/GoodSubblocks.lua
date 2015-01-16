return function(blockset)
    local blocks = {}
    local good_subblocks = require 'npge.block.good_subblocks'
    for block in blockset:iter_blocks() do
        for _, subblock in ipairs(good_subblocks(block)) do
            table.insert(blocks, subblock)
        end
    end
    local BlockSet = require 'npge.model.BlockSet'
    return BlockSet(blockset:sequences(), blocks)
end
