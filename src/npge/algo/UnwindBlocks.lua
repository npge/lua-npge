-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

local function mergeSequences(prefix2blockset)
    local blocksets = {}
    local BlockSet = require 'npge.model.BlockSet'
    for prefix, blockset in pairs(prefix2blockset) do
        local seqs = blockset:sequences()
        table.insert(blocksets, BlockSet(seqs, {}))
    end
    local unpack = require 'npge.util.unpack'
    local Merge = require 'npge.algo.Merge'
    return Merge(unpack(blocksets)):sequences()
end

return function(consensus_bs, prefix2blockset)
    local blocks = {}
    for block in consensus_bs:iterBlocks() do
        local unwind = require 'npge.block.unwind'
        local new_block = unwind(block, prefix2blockset)
        if new_block then
            table.insert(blocks, new_block)
        end
    end
    --
    local sequences = mergeSequences(prefix2blockset)
    local BlockSet = require 'npge.model.BlockSet'
    return BlockSet(sequences, blocks)
end
