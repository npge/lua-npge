-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2016 Boris Nagaev
-- See the LICENSE file for terms of use.

local function excludeBetterOrEqual(f1, betterOrEqual, blockset)
    local exclude = require 'npge.fragment.exclude'
    for _, f2 in ipairs(blockset:overlappingFragments(f1)) do
        local b2 = assert(blockset:blockByFragment(f2))
        -- exclude if b2 is better or equal to b1
        if betterOrEqual(b2) then
            f1 = exclude(f1, f2)
            if not f1 then
                return f1
            end
        end
    end
    return f1
end

local function iteration(block, betterOrEqual, blockset)
    -- find slice not overlapping with better or equal blocks
    local s2f = require 'npge.fragment.sequenceToFragment'
    local for_block = {}
    for f1 in block:iterFragments() do
        local f2 = excludeBetterOrEqual(f1, betterOrEqual,
            blockset)
        if f2 == f1 then
            table.insert(for_block, {f1, block:text(f1)})
        elseif f2 then
            local fstart = s2f(f1, f2:start())
            local fstop = s2f(f1, f2:stop())
            local start = block:fragment2block(f1, fstart)
            local stop = block:fragment2block(f1, fstop)
            local row = block:text(f1):sub(start + 1, stop + 1)
            local prefix_len = start
            local suffix_len = block:length() - stop - 1
            local prefix = ('-'):rep(prefix_len)
            local suffix = ('-'):rep(suffix_len)
            local row2 = prefix .. row .. suffix
            table.insert(for_block, {f2, row2})
        end
    end
    if #for_block == 0 then
        return nil
    end
    local npge = require 'npge'
    local Block = require 'npge.model.Block'
    return npge.block.refine(Block(for_block))
end

-- multiple iterations are needed when block gets worse

return function(block, blockset, exclude_all)
    local better = require 'npge.block.better'
    local function betterOrEqual(b2)
        return not better(block, b2)
    end
    if exclude_all then
        betterOrEqual = function()
            return true
        end
    end
    local prev_state
    while block ~= prev_state do
        local next_state = iteration(block, betterOrEqual,
            blockset)
        if not next_state then
            return nil
        end
        prev_state = block
        block = next_state
    end
    -- check that block is better than all overlapping blocks
    local Overlapping = require 'npge.algo.Overlapping'
    for _, block2 in ipairs(Overlapping(blockset, block)) do
        assert(not betterOrEqual(block2))
    end
    return block
end
