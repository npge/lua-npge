-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

return function(minuend, subtrahend)
    local blocks = {}
    for block, name in minuend:iterBlocks() do
        if not subtrahend:hasBlock(block) then
            blocks[name] = block
        end
    end
    local BlockSet = require 'npge.model.BlockSet'
    return BlockSet(minuend:sequences(), blocks)
end
