-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

return function(blockset)
    local WSTF = require 'npge.io.WriteSequencesToFasta'
    local toFasta = require 'npge.util.toFasta'
    return coroutine.wrap(function()
        if not blockset:isPartition() then
            for line in WSTF(blockset) do
                coroutine.yield(line)
            end
        end
        for block, name in blockset:iterBlocks() do
            coroutine.yield('\n') -- empty line
            -- TODO move to npge.block.toFasta
            for fragment in block:iterFragments() do
                local id = fragment:id()
                local block_str = ("block=%s"):format(name)
                local text = block:text(fragment)
                coroutine.yield(toFasta(id, block_str, text))
            end
        end
    end)
end
