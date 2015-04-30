-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

return function(block)
    local genomes = {}
    for fragment in block:iterFragments() do
        local genome = assert(fragment:sequence():genome(),
                "Can't get genome of " .. fragment:id())
        if genomes[genome] then
            return true
        end
        genomes[genome] = true
    end
    return false
end
