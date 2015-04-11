-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

return {
    array = function(x)
        local clone = {}
        for _, item in ipairs(x) do
            table.insert(clone, item)
        end
        return clone
    end,

    arrayFromIt = function(it)
        local clone = {}
        for item in it do
            table.insert(clone, item)
        end
        return clone
    end,

    dict = function(x)
        local clone = {}
        for key, value in pairs(x) do
            clone[key] = value
        end
        return clone
    end,

    dict_from_it = function(it)
        local clone = {}
        for key, value in it do
            clone[key] = value
        end
        return clone
    end,
}
