-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2016 Boris Nagaev
-- See the LICENSE file for terms of use.

return function(block)
    local genomes_set = {}
    for fragment in block:iterFragments() do
        local genome = assert(fragment:sequence():genome(),
                "Can't get genome of " .. fragment:id())
        if not genomes_set[genome] then
            genomes_set[genome] = true
        end
    end
    local genomes = {}
    for genome, _ in pairs(genomes_set) do
        table.insert(genomes, genome)
    end
    return genomes
end
