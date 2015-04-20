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
    for _, item in ipairs(items) do
        local igroup = math.random(1, ngroups)
        table.insert(groups[igroup], item)
    end
    return groups
end
