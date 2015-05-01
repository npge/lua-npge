-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

return function(blockset)
    local Genomes = require 'npge.algo.Genomes'
    local genomes_number = #(Genomes(blockset))
    --
    local giveName = require 'npge.block.giveName'
    local blocks = {}
    for block in blockset:iterBlocks() do
        local base_name = giveName(block, genomes_number)
        local name = base_name
        local n = 1
        while blocks[name] do
            name = base_name .. 'n' .. n
            n = n + 1
        end
        blocks[name] = block
    end
    local BlockSet = require 'npge.model.BlockSet'
    return BlockSet(blockset:sequences(), blocks)
end
