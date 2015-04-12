-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

local function findLongGap(rows, block_length, min_length)
    -- return min and max block positions of long gap OR nil
    for _, row in ipairs(rows) do
        local gap_length = 0
        for i = 1, block_length do
            if row:sub(i, i) == '-' then
                gap_length = gap_length + 1
            else
                if gap_length >= min_length then
                    local stop = i - 1
                    local start = i - gap_length
                    return start, stop
                end
                gap_length = 0
            end
        end
        if gap_length >= min_length then
            local stop = block_length - 1
            local start = block_length - gap_length
            return start, stop
        end
    end
end

local function groupLength(group)
    return group.stop - group.start + 1
end

local cpp = require 'npge.cpp'
local findIdentGroups = cpp.alignment.findIdentGroups

local function makeGroup(groups, i, i1)
    assert(i >= 1)
    assert(i <= i1)
    assert(i1 <= #groups)
    return {start=groups[i].start, stop=groups[i1].stop}
end

local function groupOfMinLength(groups, i, min_length)
    -- returns index of first group index of last group or nil
    for i1 = i, #groups do
        local group = makeGroup(groups, i, i1)
        if groupLength(group) >= min_length then
            return i1
        end
    end
end


local function groupIdentity(rows, group)
    local identity = require 'npge.alignment.identity'
    return identity(rows, group.start, group.stop)
end

local function findMinGoodGroup(rows, groups)
    local config = require 'npge.config'
    local min_length = config.general.MIN_LENGTH
    local min_ident = config.general.MIN_IDENTITY
    local identity = require 'npge.block.identity'
    for i = 1, #groups do
        local i1 = groupOfMinLength(groups, i, min_length)
        if i1 then
            local g = makeGroup(groups, i, i1)
            local ident = groupIdentity(rows, g)
            if g and not identity.less(ident, min_ident) then
                return i, i1
            end
        end
    end
end

local function extendGoodGroup(rows, groups, i, i1)
    local config = require 'npge.config'
    local min_ident = config.general.MIN_IDENTITY
    local less = require 'npge.block.identity'.less
    local identity = require 'npge.alignment.identity'
    local group = makeGroup(groups, i, i1)
    local _, ident, all = groupIdentity(rows, group)
    while i1 < #groups do
        local start = groups[i1].stop + 1
        local stop = groups[i1 + 1].stop
        local _, ident1, all1 = identity(rows, start, stop)
        local new_id = (ident + ident1) / (all + all1)
        if not less(new_id, min_ident) then
            ident = ident + ident1
            all = all + all1
            i1 = i1 + 1
        else
            break
        end
    end
    while i > 1 do
        local start = groups[i - 1].start
        local stop = groups[i].start - 1
        local _, ident1, all1 = identity(rows, start, stop)
        local new_id = (ident + ident1) / (all + all1)
        if not less(new_id, min_ident) then
            ident = ident + ident1
            all = all + all1
            i = i - 1
        else
            break
        end
    end
    return i, i1
end

local function findGoodGroup(rows, groups)
    local i, i1 = findMinGoodGroup(rows, groups)
    if not i or not i1 then
        return nil
    end
    local i, i1 = extendGoodGroup(rows, groups, i, i1)
    return makeGroup(groups, i, i1)
end

local function removePureGapCols(for_block)
    assert(#for_block >= 2)
    local frag2row = {}
    for _, pair in ipairs(for_block) do
        local fragment = pair[1]
        frag2row[fragment] = {}
    end
    local length = #(for_block[1][2])
    for col = 1, length do
        local all_gaps = true
        for _, pair in ipairs(for_block) do
            local row = pair[2]
            local letter = row:sub(col, col)
            assert(#letter == 1)
            if letter ~= '-' then
                all_gaps = false
                break
            end
        end
        if not all_gaps then
            for _, pair in ipairs(for_block) do
                local fragment = pair[1]
                local row = pair[2]
                local letter = row:sub(col, col)
                assert(#letter == 1)
                table.insert(frag2row[fragment], letter)
            end
        end
    end
    local for_block1 = {}
    for fragment, row in pairs(frag2row) do
        row = table.concat(row)
        table.insert(for_block1, {fragment, row})
    end
    return for_block1
end

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
    for_block = removePureGapCols(for_block)
    local Block = require 'npge.model.Block'
    return Block(for_block)
end

local function goodSubblocks(block)
    local isGood = require 'npge.block.isGood'
    if isGood(block) then
        return {block}
    end
    -- try to find subblocks of same size as original block
    local config = require 'npge.config'
    local min_length = config.general.MIN_LENGTH
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
    -- find long gap
    local gap_start, gap_stop = findLongGap(rows,
        block:length(), min_length)
    local slice = require 'npge.block.slice'
    if gap_start and gap_stop then
        local subblocks = {}
        local concat = require 'npge.util.concatArrays'
        if gap_start > 0 then
            local left_block = slice(block, 0, gap_start - 1)
            local left_subblocks = goodSubblocks(left_block)
            subblocks = concat(subblocks, left_subblocks)
        end
        if gap_stop < block:length() - 1 then
            local right_block = slice(block, gap_stop + 1,
                block:length() - 1)
            local right_subblocks = goodSubblocks(right_block)
            subblocks = concat(subblocks, right_subblocks)
        end
        if #subblocks > 0 then
            return subblocks
        end
    end
    -- no long gaps here
    -- find continous groups of identical columns
    local min_cols = config.general.MIN_END_IDENTICAL_COLUMNS
    local ident_groups = findIdentGroups(rows, min_cols)
    local good_slice = findGoodGroup(rows, ident_groups)
    if good_slice then
        local subblock = slice(block, good_slice.start,
            good_slice.stop)
        assert(isGood(subblock))
        return {subblock}
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
