-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

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
