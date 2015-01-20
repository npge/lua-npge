return function(block)
    local reverse = require 'npge.block.reverse'
    local neg_ori = 0
    for fragment in block:iter_fragments() do
        if fragment:ori() == -1 then
            neg_ori = neg_ori + 1
        end
    end
    if neg_ori * 2 > block:size() then
        return reverse(block)
    elseif neg_ori * 2 < block:size() then
        return block
    else
        -- one half ori=1, one half ori=-1
        assert(neg_ori * 2 == block:size())
        -- find minimal fragment and use its ori
        local min_fragment
        for fragment in block:iter_fragments() do
            if not min_fragment or fragment < min_fragment then
                min_fragment = fragment
            end
        end
        assert(min_fragment)
        if min_fragment:ori() == 1 then
            return block
        else
            return reverse(block)
        end
    end
end
