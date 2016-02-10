-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2016 Boris Nagaev
-- See the LICENSE file for terms of use.

return function(blockset)
    local blocks = {}
    for block in blockset:iterBlocks() do
        local align = require 'npge.block.align'
        local block1 = align(block)
        local identity = require 'npge.block.identity'
        if identity(block1) > identity(block) then
            table.insert(blocks, block1)
        else
            table.insert(blocks, block)
        end
    end
    local BlockSet = require 'npge.model.BlockSet'
    return BlockSet(blockset:sequences(), blocks)
end
