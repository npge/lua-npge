-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2016 Boris Nagaev
-- See the LICENSE file for terms of use.

local function SubBlockSet(blockset, sequences)
    -- create set of sequences of interest
    local names_set = {}
    for _, sequence in ipairs(sequences) do
        assert(blockset:hasSequence(sequence))
        names_set[sequence:name()] = true
    end
    -- filter fragments in blocks
    local removePureGaps = require 'npge.alignment.removePureGaps'
    local Block = require 'npge.model.Block'
    local blocks = {}
    for block in blockset:iterBlocks() do
        local fragments = {}
        local texts = {}
        for fragment in block:iterFragments() do
            local name = fragment:sequence():name()
            if names_set[name] then
                local text = block:text(fragment)
                table.insert(fragments, fragment)
                table.insert(texts, text)
            end
        end
        if fragments[1] then
            texts = removePureGaps(texts)
            local rows = {}
            for i = 1, #fragments do
                rows[i] = {fragments[i], texts[i]}
            end
            local new_block = Block(rows)
            table.insert(blocks, new_block)
        end
    end
    local BlockSet = require 'npge.model.BlockSet'
    return BlockSet(sequences, blocks)
end

return SubBlockSet
