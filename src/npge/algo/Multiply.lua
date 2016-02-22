-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2016 Boris Nagaev
-- See the LICENSE file for terms of use.

-- ori of fragments is inherited from bs1
local function Multiply(bs1, bs2)
    assert(bs1:isPartition(), "blockset is not partition")
    assert(bs2:isPartition(), "blockset is not partition")
    assert(bs1:sameSequences(bs2),
           "blocksets use different sets of sequences")
    local model = require 'npge.model'
    local overlaps = require 'npge.fragment.overlaps'
    local blocks = {}
    for block1 in bs1:iterBlocks() do
        local block2_to_fragments = {}
        for f1 in block1:iterFragments() do
            local fragments2 = bs2:overlappingFragments(f1)
            for _, f2 in ipairs(fragments2) do
                local block2 = assert(bs2:blockByFragment(f2))
                if not block2_to_fragments[block2] then
                    block2_to_fragments[block2] = {}
                end
                local oo = overlaps(f1, f2)
                assert(#oo >= 1)
                -- TODO if #oo == 2, split to two new blocks
                for _, o in ipairs(oo) do
                    table.insert(block2_to_fragments[block2], o)
                end
            end
        end
        for _, oo in pairs(block2_to_fragments) do
            -- TODO preserve alignment
            table.insert(blocks, model.Block(oo))
        end
    end
    local bs3 = model.BlockSet(bs1:sequences(), blocks)
    assert(bs3:isPartition())
    return bs3
end

return Multiply
