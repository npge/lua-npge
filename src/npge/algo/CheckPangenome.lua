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
        return t == 'u' or t == 'm'
    end

    local function less(block1, block2)
        local s1 = block1:size()
        local s2 = block2:size()
        local l1 = block1:length()
        local l2 = block2:length()
        return s1 < s2 or (s1 == s2 and l1 < l2)
    end

    local function blockNames(blocks)
        local names = {}
        for _, block in ipairs(blocks) do
            table.insert(names, blockset:nameByBlock(block))
        end
        return names
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

    local genomes = npge.algo.Genomes(blockset)

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
        if npge.block.orient(block) ~= block then
            fail("Block %s should be inverted", name)
        end
    end

    local function inspectPart(i, part)
        assert(part:size() >= 2)
        local part_name = npge.block.giveName(part, #genomes)
        local blocks = npge.algo.Overlapping(blockset, part)
        warning(" part %d (%s) overlaps with %d blocks",
            i, part_name, #blocks)
        local overlaps_greater
        local block_names = {}
        for _, block in ipairs(blocks) do
            local block_name = blockset:nameByBlock(block)
            table.insert(block_names, block_name)
            local t = npge.block.parseName(block_name)
            if not badType(t) and not less(block, part) then
                local msg = [[  part %d (%s) overlaps with block
                    %s, which is greater or equal to the part.
                    That is why this part was discarded.]]
                warning(msg, i, part_name, block_name)
                overlaps_greater = true
            end
        end
        if not overlaps_greater then
            local names_str = table.concat(block_names, ', ')
            local msg = [[  part %d (%s) overlaps with
                blocks %s, all of them are minor, unique or
                less than the part. This part must be included
                into the pangenome!]]
            fail(msg, i, part_name, names_str)
        end
    end

    -- blast
    local cons = npge.algo.ConsensusSequences(blockset)
    local cons_hits = npge.algo.BlastHits(cons, cons)
    warning("There are %d blast hits", cons_hits:size())
    for cons_hit in cons_hits:iterBlocks() do
        local name = npge.block.hitName(cons_hit)
        local hit = npge.block.unwind(cons_hit, {['']=blockset})
        local good_parts = npge.block.goodSubblocks(hit)
        warning("Hit %s unwinds to %d good parts",
            name, #good_parts)
        for i, part in ipairs(good_parts) do
            inspectPart(i, part)
        end
    end

    -- join
    local joined = npge.algo.Join(blockset)
    warning("Joining neighbour blocks produces %d blocks",
        joined:size())
    for i, block in ipairs(joined:blocks()) do
        local block_name = npge.block.giveName(block, #genomes)
        local blocks = npge.algo.Overlapping(blockset, block)
        local names = table.concat(blockNames(blocks), ', ')
        local good_parts = npge.block.goodSubblocks(block)
        warning([[Joined block %s (%s, composed from %s)
            unwinds to %d good parts]],
            i, block_name, names, #good_parts)
        for i, part in ipairs(good_parts) do
            inspectPart(i, part)
        end
    end

    -- extend
    local config = require 'npge.config'
    local extend_length = config.general.MIN_LENGTH
    for block, block_name in blockset:iterBlocks() do
        local block2 = npge.block.extend(block, extend_length)
        local blocks = npge.algo.Overlapping(blockset, block2)
        local names = table.concat(blockNames(blocks), ', ')
        local good_parts = npge.block.goodSubblocks(block2)
        warning([[Block %s extended to %d positions left and
            right overlaps with blocks %s and unwinds to %d
            good parts]],
            block_name, extend_length, names, #good_parts)
        for i, part in ipairs(good_parts) do
            inspectPart(i, part)
        end
    end

    return status, table.concat(messages, "\n")
end
