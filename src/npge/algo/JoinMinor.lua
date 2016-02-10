-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2016 Boris Nagaev
-- See the LICENSE file for terms of use.

local function logicalNeighbour(f, ori, blockset)
    if ori * f:ori() == 1 then
        return blockset:next(f)
    else
        return blockset:prev(f)
    end
end

local function joinMinor(block, bs, joined, joinable)
    -- joinable neighbours
    -- key is ori
    -- value is map from neighbour to ori of block's fragment
    local neighbours = {[-1] = {}, [1] = {}}
    -- visit each fragment, inspect neighbours
    for f in block:iterFragments() do
        for ori = -1, 1, 2 do
            local neighbour = logicalNeighbour(f, ori, bs)
            if neighbour and joinable[neighbour] then
                neighbours[ori][neighbour] = f:ori()
            end
        end
    end
    -- inspect joinable neighbours
    local reverse = require 'npge.fragment.reverse'
    for ori = -1, 1, 2 do
        local fragments = {}
        for neighbour, f_ori in pairs(neighbours[ori]) do
            if joinable[neighbour] then
                if f_ori == -1 then
                    -- keep orientations of block's fragments
                    neighbour = reverse(neighbour)
                end
                table.insert(fragments, neighbour)
            end
        end
        if #fragments >= 2 then
            local Block = require 'npge.model.Block'
            local minor_block = Block(fragments)
            table.insert(joined, minor_block)
            for neighbour, f_ori in pairs(neighbours[ori]) do
                joinable[neighbour]  = nil
            end
        end
    end
end

return function(blockset)
    -- join minor blocks of size 1, which follow the same
    -- non-minor block (respecting non-minor block orientation)
    -- return joined minor blocks
    local npge = require 'npge'
    assert(not npge.algo.HasOverlap(blockset))
    local genomes = npge.algo.Genomes(blockset)
    local ngenomes = #genomes
    local joinable = {} -- fragment
    local size2blocks = {}
    local max_size = 0
    for block in blockset:iterBlocks() do
        local t = npge.block.blockType(block, ngenomes)
        local size = block:size()
        if t == 'minor' and block:size() == 1 then
            local fragment = block:fragments()[1]
            joinable[fragment] = true
        end
        if t == 'stable' or t == 'half' or t == 'repeat' then
            max_size = math.max(max_size, size)
            if not size2blocks[size] then
                size2blocks[size] = {}
            end
            table.insert(size2blocks[size], block)
        end
    end
    --
    local joined = {}
    for size = max_size, 2, -1 do
        if size2blocks[size] then
            for _, block in ipairs(size2blocks[size]) do
                joinMinor(block, blockset, joined, joinable)
            end
        end
    end
    -- return
    local BlockSet = require 'npge.model.BlockSet'
    local joined_bs = BlockSet(blockset:sequences(), joined)
    assert(not npge.algo.HasOverlap(joined_bs))
    return joined_bs
end
