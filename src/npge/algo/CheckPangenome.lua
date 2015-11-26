-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

return function(blockset)
    local npge = require 'npge'

    local status = true
    local messages = {}
    local function warning(text, ...)
        text = text:format(...)
        text = text:gsub('\n *', ' ')
        table.insert(messages, text)
    end
    local function fail(...)
        status = false
        warning("Error:")
        warning(...)
    end

    -- returns true for "m" (minor) and "u" (unique)
    local function badType(t)
        return t == 'u' or t == 'm' or t == 'b'
    end

    local genomes = npge.algo.Genomes(blockset)

    local function blockNames(blocks)
        local names = {}
        for _, block in ipairs(blocks) do
            local name = blockset:nameByBlock(block)
            if name == '' then
                name = npge.block.giveName(block, #genomes)
            end
            table.insert(names, name)
        end
        return table.concat(names, ', ')
    end

    if not blockset:isPartition() then
        fail("The blockset is not a partition")
    end

    -- neighbours can not be both be unique or minor
    for sequence in blockset:iterSequences() do
        for f in blockset:iterFragments(sequence) do
            local p = blockset:prev(f)
            if p and p ~= f then
                local b1 = assert(blockset:blockByFragment(f))
                local b2 = assert(blockset:blockByFragment(p))
                local name1 = blockset:nameByBlock(b1)
                local name2 = blockset:nameByBlock(b2)
                local t1 = npge.block.parseName(name1)
                local t2 = npge.block.parseName(name2)
                if badType(t1) and badType(t2) then
                    fail("Blocks %s and %s are neighbours",
                        name1, name2)
                end
            end
        end
    end

    -- block names must correspond their types
    -- block must be in right orientation
    -- Quality of s,h,r-blocks is part of this step
    for block, name in blockset:iterBlocks() do
        local t, size, length, n = npge.block.parseName(name)
        if size ~= block:size() then
            fail("Block %s has size %d", name, block:size())
        end
        if length ~= block:length() then
            fail("Block %s has length %d", name, block:length())
        end
        local true_name = npge.block.giveName(block, #genomes)
        local t2 = npge.block.parseName(true_name)
        if t2 ~= t then
            fail("Block %s should have type %s", name, t2)
        end
        if t2 == 'b' then
            fail("Bad block: %s", name)
        end
        if npge.block.orient(block) ~= block then
            fail("Block %s should be inverted", name)
        end
    end

    local function inspectBlock(name, block)
        -- apply excludeSelfOverlap after goodSubblocks?
        block = npge.block.excludeSelfOverlap(block)[1]
        assert(block, "Whole block is a self-overlap")
        warning("")
        warning("Inspecting %s", name)
        local blocks = npge.algo.Overlapping(blockset, block)
        local names = blockNames(blocks)
        warning(" %s overlaps with %d blocks: %s",
            name, #blocks, names)
        local good_parts = npge.block.goodSubblocks(block)
        warning(" %s produces %d good parts",
            name, #good_parts)
        if #good_parts > 0 then
            local better_parts = npge.block.betterSubblocks(
                block, blockset)
            if #better_parts == 0 then
                warning([[ All of these good parts were
                    eliminated by better or equal blocks]])
            else
                local names = blockNames(better_parts)
                fail(" The following %d parts can be added: %s",
                    #better_parts, names)
            end
        end
    end

    -- blast
    local cons = npge.algo.ConsensusSequences(blockset)
    local cons_hits = npge.algo.BlastHits(cons, cons)
    warning("There are %d blast hits", cons_hits:size())
    for cons_hit in cons_hits:iterBlocks() do
        local name = npge.block.hitName(cons_hit)
        local hit = npge.block.unwind(cons_hit, {['']=blockset})
        inspectBlock('Hit ' .. name, hit)
    end

    -- join
    local joined = npge.algo.Join(blockset)
    warning("Joining neighbour blocks produces %d blocks",
        joined:size())
    for i, block in ipairs(joined:blocks()) do
        local block_name = npge.block.giveName(block, #genomes)
        inspectBlock('Joined ' .. block_name, block)
    end

    -- extend
    local config = require 'npge.config'
    local ex_len = config.general.MIN_LENGTH
    local extend = npge.block.extend
    for block, block_name in blockset:iterBlocks() do
        if not badType(npge.block.parseName(block_name)) then
            local e = extend(block, ex_len)
            inspectBlock('Extended from ' .. block_name, e)
        end
    end

    return status, table.concat(messages, "\n")
end
