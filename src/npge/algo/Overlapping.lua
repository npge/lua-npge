-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2016 Boris Nagaev
-- See the LICENSE file for terms of use.

return function(blockset, block)
    local blocks_set = {}
    for f1 in block:iterFragments() do
        local fragments = blockset:overlappingFragments(f1)
        for _, f2 in ipairs(fragments) do
            local block1 = blockset:blockByFragment(f2)
            blocks_set[block1] = true
        end
    end
    local blocks = {}
    for block1, _ in pairs(blocks_set) do
        table.insert(blocks, block1)
    end
    return blocks
end
