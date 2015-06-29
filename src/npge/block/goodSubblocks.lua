-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

local function removeMostDistant(block)
    local consensus = require 'npge.block.consensus'
    local identity = require 'npge.alignment.identity'
    local c = consensus(block)
    local worst_ident, worst_fragment
    for fragment in block:iterFragments() do
        local row = block:text(fragment)
        local ident = identity({c, row})
        if not worst_ident or ident < worst_ident then
            worst_ident = ident
            worst_fragment = fragment
        end
    end
    assert(worst_fragment)
    local for_block = {}
    for fragment in block:iterFragments() do
        if fragment ~= worst_fragment then
            local row = block:text(fragment)
            table.insert(for_block, {fragment, row})
        end
    end
    assert(#for_block == block:size() - 1)
    local refine = require 'npge.block.refine'
    local Block = require 'npge.model.Block'
    return refine(Block(for_block))
end

local function goodSubblocks(block)
    -- try to find subblocks of same size as original block
    local config = require 'npge.config'
    local min_length = config.general.MIN_LENGTH
    local min_identity = config.general.MIN_IDENTITY
    local min_end = config.general.MIN_END
    local frame_length = config.general.FRAME_LENGTH
    if block:length() < min_length then
        -- block is too short
        return {}
    end
    -- block of 1 fragments: nothing to do
    if block:size() < 2 then
        return {}
    end
    -- make rows
    local rows = {}
    for fragment in block:iterFragments() do
        table.insert(rows, block:text(fragment))
    end
    -- find continous groups of identical columns
    local goodColumns = require 'npge.alignment.goodColumns'
    local goodSlices = require 'npge.alignment.goodSlices'
    local slice = require 'npge.block.slice'
    local good_col = goodColumns(rows)
    local good_slices = goodSlices(good_col,
            frame_length, min_end,
            min_identity, min_length)
    if #good_slices > 0 then
        local result = {}
        for _, s in ipairs(good_slices) do
            local subblock = slice(block, s[1], s[2])
            table.insert(result, subblock)
        end
        return result
    end
    -- block of 2 fragments: nothing to do
    if block:size() <= 2 then
        return {}
    end
    -- try to remove the most distant fragment
    local block1 = removeMostDistant(block)
    return goodSubblocks(block1)
end

return goodSubblocks
