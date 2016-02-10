-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2016 Boris Nagaev
-- See the LICENSE file for terms of use.

return function(blockset)
    local blocks = {}
    local goodSubblocks = require 'npge.block.goodSubblocks'
    for block in blockset:iterBlocks() do
        for _, subblock in ipairs(goodSubblocks(block)) do
            table.insert(blocks, subblock)
        end
    end
    local BlockSet = require 'npge.model.BlockSet'
    return BlockSet(blockset:sequences(), blocks)
end
