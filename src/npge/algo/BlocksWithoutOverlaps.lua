return function(orig, added)
    assert(orig:same_sequences(added))
    local concat = require 'npge.util.concat_arrays'
    local BlockSet = require 'npge.model.BlockSet'
    local bs = BlockSet(orig:sequences(), {})
    local blocks = {}
    local update_bs = function()
        bs = BlockSet(orig:sequences(),
            concat(bs:blocks(), blocks))
        blocks = {}
    end
    local overlapping = function(block)
        for f in block:iter_fragments() do
            if #(bs:overlapping_fragments(f)) > 0 then
                return true
            end
        end
        local seq2fragments = {}
        for f in block:iter_fragments() do
            if not seq2fragments[f:sequence()] then
                seq2fragments[f:sequence()] = {}
            end
            table.insert(seq2fragments[f:sequence()], f)
        end
        for _, block1 in ipairs(blocks) do
            for f in block1:iter_fragments() do
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
    for block in orig:iter_blocks() do
        from_orig[block] = true
    end
    local bb = concat(orig:blocks(), added:blocks())
    table.sort(bb, function(b1, b2)
        -- sort by size, then length, prefer blocks from orig
        local arrays_less = require 'npge.util.arrays_less'
        local orig1 = from_orig[b1] and 1 or 2
        local orig2 = from_orig[b2] and 1 or 2
        return arrays_less({-b1:size(), -b1:length(), orig1},
            {-b2:size(), -b2:length(), orig2})
    end)
    for _, block in ipairs(bb) do
        if not overlapping(block) then
            table.insert(blocks, block)
            if #blocks > 10 then
                update_bs()
            end
        end
    end
    update_bs()
    return bs
end