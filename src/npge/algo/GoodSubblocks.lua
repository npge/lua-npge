-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

return function(blockset)
    local blocks = {}
    local good_subblocks = require 'npge.block.good_subblocks'
    for block in blockset:iterBlocks() do
        for _, subblock in ipairs(good_subblocks(block)) do
            table.insert(blocks, subblock)
        end
    end
    local BlockSet = require 'npge.model.BlockSet'
    return BlockSet(blockset:sequences(), blocks)
end
