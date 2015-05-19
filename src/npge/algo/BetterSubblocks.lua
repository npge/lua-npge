-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

return function(new, old)
    local blocks = {}
    local betterSubblocks = require 'npge.block.betterSubblocks'
    for b in new:iterBlocks() do
        for _, subblock in ipairs(betterSubblocks(b, old)) do
            table.insert(blocks, subblock)
        end
    end
    local BlockSet = require 'npge.model.BlockSet'
    return BlockSet(new:sequences(), blocks)
end
