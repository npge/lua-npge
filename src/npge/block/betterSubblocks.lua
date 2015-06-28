-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

local function iteration(block, blockset)
    local excl_bte = require 'npge.block.excludeBetterOrEqual'
    local goodSubblocks = require 'npge.block.goodSubblocks'
    local stack = {block}
    local result_better = {}
    local result_good
    while #stack > 0 do
        local b = table.remove(stack)
        local b1 = excl_bte(b, blockset)
        if b1 then
            local good = goodSubblocks(b1)
            if #good == 1 and good[1] == b then
                table.insert(result_better, b)
            else
                for _, b2 in ipairs(good) do
                    -- it isn't guaranteed that b2 < b
                    -- because of gaps
                    table.insert(stack, b2)
                end
                if #good >= 1 and not result_good then
                    -- save some good block;
                    -- it will be excluded,
                    -- if no better blocks found
                    result_good = good[1]
                end
            end
        end
    end
    return result_better, result_good
end

local function betterSubblocks(block, blockset)
    local better, good = iteration(block, blockset)
    if #better >= 1 then
        return better
    end
    if not good then
        return {}
    end
    -- No results, but there is a good block
    -- Try to exclude it from the block
    local npge = require 'npge'
    local bs = npge.model.BlockSet(blockset:sequences(),
        {good})
    local all = true
    block = npge.block.excludeBetterOrEqual(block, bs, all)
    -- tail call
    return betterSubblocks(block, blockset)
end

return betterSubblocks
