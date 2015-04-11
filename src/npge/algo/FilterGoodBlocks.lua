-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

return function(blockset)
    local isGood = require 'npge.block.isGood'
    local blocks = {}
    for block in blockset:iterBlocks() do
        if isGood(block) then
            table.insert(blocks, block)
        end
    end
    local BlockSet = require 'npge.model.BlockSet'
    return BlockSet(blockset:sequences(), blocks)
end
