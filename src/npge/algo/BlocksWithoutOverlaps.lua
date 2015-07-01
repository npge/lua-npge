-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

return function(orig, added)
    if added then
        assert(orig:sameSequences(added))
    end
    local concat = require 'npge.util.concatArrays'
    local BlockSet = require 'npge.model.BlockSet'
    local bs = BlockSet(orig:sequences(), {})
    local blocks = {}
    local function updateBs()
        bs = BlockSet(orig:sequences(),
            concat(bs:blocks(), blocks))
        blocks = {}
    end
    local hasSelfOverlap = require 'npge.block.hasSelfOverlap'
    local function overlapping(block)
        if hasSelfOverlap(block) then
            return true
        end
        for f in block:iterFragments() do
            if #(bs:overlappingFragments(f)) > 0 then
                return true
            end
        end
        local seq2fragments = {}
        for f in block:iterFragments() do
            if not seq2fragments[f:sequence()] then
                seq2fragments[f:sequence()] = {}
            end
            table.insert(seq2fragments[f:sequence()], f)
        end
        for _, block1 in ipairs(blocks) do
            for f in block1:iterFragments() do
                local ff = seq2fragments[f:sequence()]
                if ff then
                    for _, f1 in ipairs(ff) do
                        if f:common(f1) > 0 then
                            return true
                        end
                    end
                end
            end
        end
        return false
    end
    local from_orig = {}
    for block in orig:iterBlocks() do
        from_orig[block] = true
    end
    local bb = orig:blocks()
    if added then
        bb = concat(bb, added:blocks())
    end
    local better = require 'npge.block.better'
    table.sort(bb, function(b1, b2)
        if better(b1, b2) then
            return true
        elseif better(b2, b1) then
            return false
        else
            local orig1 = from_orig[b1] and 1 or 2
            local orig2 = from_orig[b2] and 1 or 2
            return orig1 < orig2
        end
    end)
    for _, block in ipairs(bb) do
        if not overlapping(block) then
            table.insert(blocks, block)
            if #blocks > 10 then
                updateBs()
            end
        end
    end
    updateBs()
    return bs
end
