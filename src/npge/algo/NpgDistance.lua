-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2016 Boris Nagaev
-- See the LICENSE file for terms of use.

local function NpgDistance(
        npg1,
        npg2,
        conflicts,
        _ --[[common]]
    )
    local Genomes = require 'npge.algo.Genomes'
    local Overlapping = require 'npge.algo.Overlapping'
    local genomes_number = Genomes(npg1)
    local blockType = require 'npge.block.blockType'

    local function isCounted(block)
        for _, npg in ipairs({npg1, npg2}) do
            local blocks = Overlapping(npg, block)
            assert(#blocks == 1)
            if blockType(blocks[1], genomes_number) == 'minor' then
                return false
            end
        end
        return true
    end

    local abs_dist = 0
    for conflict_block in conflicts:iterBlocks() do
        if isCounted(conflict_block) then
            for conflict_fragment in conflict_block:iterFragments() do
                abs_dist = abs_dist + conflict_fragment:length()
            end
        end
    end

    local total_length = 0
    for seq in npg1:iterSequences() do
        total_length = total_length + seq:length()
    end

    return abs_dist, abs_dist / total_length
end

return NpgDistance
