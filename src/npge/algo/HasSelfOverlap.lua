-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

return function(blockset)
    local hasSelfOverlap = require 'npge.block.hasSelfOverlap'
    for block in blockset:iterBlocks() do
        if hasSelfOverlap(block) then
            return true
        end
    end
    return false
end
