-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

return function(blockset)
    local WSTF = require 'npge.io.WriteSequencesToFasta'
    return coroutine.wrap(function()
        -- TODO don't dump sequences if is partition
        for line in WSTF(blockset) do
            coroutine.yield(line)
        end
        for block, name in blockset:iterBlocks() do
            coroutine.yield('\n') -- empty line
            -- TODO move to npge.block.toFasta
            for fragment in block:iterFragments() do
                local id = fragment:id()
                local block_str = ("block=%s"):format(name)
                coroutine.yield((">%s %q\n"):format(id, block_str))
                coroutine.yield(block:text(fragment) .. '\n')
            end
        end
    end)
end
