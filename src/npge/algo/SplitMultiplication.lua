-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2016 Boris Nagaev
-- See the LICENSE file for terms of use.

local function SplitMultiplication(npg1, npg2, mul)
    assert(npg1:isPartition())
    assert(npg2:isPartition())
    assert(mul:isPartition())
    assert(mul:sameSequences(npg1))
    assert(mul:sameSequences(npg2))
    local mul_blocks = mul:blocks()
    table.sort(mul_blocks, function(a, b)
        return b < a
    end)
    local to_npg1_block = {}
    local to_npg2_block = {}
    local Overlapping = require 'npge.algo.Overlapping'
    for _, block in ipairs(mul_blocks) do
        local npg1_blocks = Overlapping(npg1, block)
        local npg2_blocks = Overlapping(npg2, block)
        assert(#npg1_blocks == 1)
        assert(#npg2_blocks == 1)
        to_npg1_block[block] = npg1_blocks[1]
        to_npg2_block[block] = npg2_blocks[1]
    end
    local used1 = {}
    local used2 = {}
    local common = {}
    local conflicts = {}
    for _, block in ipairs(mul_blocks) do
        local npg1_blocks = Overlapping(npg1, block)
        local npg2_blocks = Overlapping(npg2, block)
        assert(#npg1_blocks == 1)
        assert(#npg2_blocks == 1)
        local block1 = npg1_blocks[1]
        local block2 = npg2_blocks[1]
        if not used1[block1] and not used2[block2] then
            used1[block1] = true
            used2[block2] = true
            table.insert(common, block)
        else
            table.insert(conflicts, block)
        end
    end
    local BlockSet = require 'npge.model.BlockSet'
    local seqs = mul:sequences()
    return BlockSet(seqs, common), BlockSet(seqs, conflicts)
end

return SplitMultiplication
