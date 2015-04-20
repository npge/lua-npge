-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

-- map items to ngroups groups of almost equal size
return function(ngroups, items)
    local groups = {}
    for i = 1, ngroups do
        table.insert(groups, {})
    end
    math.randomseed(os.time())
    for i, item in ipairs(items) do
        local igroup = ((i - 1) % ngroups) + 1
        -- swap two random groups when groups sizes are equal
        if igroup == 1 then
            local ig1 = math.random(1, ngroups)
            local ig2 = math.random(1, ngroups)
            local g1 = groups[ig1]
            groups[ig1] = groups[ig2]
            groups[ig2] = g1
        end
        -- insert item
        table.insert(groups[igroup], item)
    end
    return groups
end
