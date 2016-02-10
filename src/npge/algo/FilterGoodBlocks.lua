-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2016 Boris Nagaev
-- See the LICENSE file for terms of use.

return function(blockset)
    local isGood = require 'npge.block.isGood'
    local blocks = {}
    for block, name in blockset:iterBlocks() do
        if isGood(block) then
            blocks[name] = block
        end
    end
    local BlockSet = require 'npge.model.BlockSet'
    return BlockSet(blockset:sequences(), blocks)
end
