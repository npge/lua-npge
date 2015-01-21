local find_long_gap = function(block, min_length)
    -- return min and max block positions of long gap OR nil
    for fragment in block:iter_fragments() do
        local row = block:text(fragment)
        local gap_length = 0
        for i = 1, block:length() do
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
            local stop = block:length() - 1
            local start = block:length() - gap_length
            return start, stop
        end
    end
end

local group_length = function(group)
    return group.stop - group.start + 1
end

local find_ident_groups = function(rows, min_cols)
    local ident_groups = {}
    local ident_col = function(bp)
        local first
        for _, row in ipairs(rows) do
            local letter = row:sub(bp + 1, bp + 1)
            if letter == '-' then
                return false
            elseif first and letter ~= first then
                return false
            else
                first = letter
            end
        end
        return true
    end
    local block_length = #(rows[1])
    local group
    for bp = 0, block_length do
        local ident = ident_col(bp)
        if ident then
            if group then
                group.stop = bp
            else
                group = {start=bp, stop=bp}
            end
        elseif group then
            local length = group_length(group)
            if length > min_cols then
                table.insert(ident_groups, group)
            end
            group = nil
        end
    end
    return ident_groups
end

local make_group = function(groups, i, i1)
    assert(i >= 1)
    assert(i <= i1)
    assert(i1 <= #groups)
    return {start=groups[i].start, stop=groups[i1].stop}
end

local group_of_min_length = function(groups, i, min_length)
    -- returns index of first group index of last group or nil
    for i1 = i, #groups do
        local group = make_group(groups, i, i1)
        if group_length(group) >= min_length then
            return i1
        end
    end
end


local group_identity = function(rows, group)
    local rows1 = {}
    for _, row in ipairs(rows) do
        table.insert(rows1, row:sub(group.start + 1,
            group.stop + 1))
    end
    local identity = require 'npge.alignment.identity'
    return identity(rows1)
end

local find_min_good_group = function(rows, groups)
    local config = require 'npge.config'
    local min_length = config.general.MIN_LENGTH
    local min_ident = config.general.MIN_IDENTITY
    local identity = require 'npge.block.identity'
    for i = 1, #groups do
        local i1 = group_of_min_length(groups, i, min_length)
        if i1 then
            local g = make_group(groups, i, i1)
            local ident = group_identity(rows, g)
            if g and not identity.less(ident, min_ident) then
                return i, i1
            end
        end
    end
end

local extend_good_group = function(rows, groups, i, i1)
    local config = require 'npge.config'
    local min_ident = config.general.MIN_IDENTITY
    local identity = require 'npge.block.identity'
    local good_group = function(a, b)
        local group = make_group(groups, a, b)
        local ident = group_identity(rows, group)
        return not identity.less(ident, min_ident)
    end
    for b = i1, #groups do
        if good_group(i, b) then
            i1 = b
        else
            break
        end
    end
    for a = i, 1, -1 do
        if good_group(a, i1) then
            i = a
        else
            break
        end
    end
    return i, i1
end

local find_good_group = function(rows, groups)
    local i, i1 = find_min_good_group(rows, groups)
    if not i or not i1 then
        return nil
    end
    local i, i1 = extend_good_group(rows, groups, i, i1)
    return make_group(groups, i, i1)
end

local remove_pure_gap_cols = function(for_block)
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

local remove_most_distant = function(block)
    local consensus = require 'npge.block.consensus'
    local c = consensus(block)
    local worst_ident, worst_fragment
    for fragment in block:iter_fragments() do
        local row = block:text(fragment)
        local group = {start=0, stop=#c-1}
        local ident = group_identity({c, row}, group)
        if not worst_ident or ident < worst_ident then
            worst_ident = ident
            worst_fragment = fragment
        end
    end
    assert(worst_fragment)
    local for_block = {}
    for fragment in block:iter_fragments() do
        if fragment ~= worst_fragment then
            local row = block:text(fragment)
            table.insert(for_block, {fragment, row})
        end
    end
    for_block = remove_pure_gap_cols(for_block)
    local Block = require 'npge.model.Block'
    return Block(for_block)
end

local good_subblocks
good_subblocks = function(block)
    local is_good = require 'npge.block.is_good'
    if is_good(block) then
        return {block}
    end
    -- try to find subblocks of same size as original block
    local config = require 'npge.config'
    local min_length = config.general.MIN_LENGTH
    if block:length() < min_length then
        -- block is too short
        return {}
    end
    -- find long gap
    local gap_start, gap_stop = find_long_gap(block, min_length)
    local slice = require 'npge.block.slice'
    if gap_start and gap_stop then
        local subblocks = {}
        local concat = require 'npge.util.concat_arrays'
        if gap_start > 0 then
            local left_block = slice(block, 0, gap_start - 1)
            local left_subblocks = good_subblocks(left_block)
            subblocks = concat(subblocks, left_subblocks)
        end
        if gap_stop < block:length() - 1 then
            local right_block = slice(block, gap_stop + 1,
                block:length() - 1)
            local right_subblocks = good_subblocks(right_block)
            subblocks = concat(subblocks, right_subblocks)
        end
        if #subblocks > 0 then
            return subblocks
        end
    end
    -- no long gaps here
    -- find continous groups of identical columns
    local rows = {}
    for fragment in block:iter_fragments() do
        table.insert(rows, block:text(fragment))
    end
    local min_cols = config.general.MIN_END_IDENTICAL_COLUMNS
    local ident_groups = find_ident_groups(rows, min_cols)
    local good_slice = find_good_group(rows, ident_groups)
    if good_slice then
        local subblock = slice(block, good_slice.start,
            good_slice.stop)
        assert(is_good(subblock))
        return {subblock}
    end
    -- block of 2 fragments: nothing to do
    if block:size() <= 2 then
        return {}
    end
    -- try to remove the most distant fragment
    local block1 = remove_most_distant(block)
    return good_subblocks(block1)
end

return good_subblocks
