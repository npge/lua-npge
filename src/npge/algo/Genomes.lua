-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2016 Boris Nagaev
-- See the LICENSE file for terms of use.

return function(blockset)
    local genome2seqs = {}
    for sequence in blockset:iterSequences() do
        local genome = assert(sequence:genome(),
            ("No genome: %s"):format(sequence:name()))
        if not genome2seqs[genome] then
            genome2seqs[genome] = {}
        end
        table.insert(genome2seqs[genome], sequence)
    end
    local genomes = {}
    for genome, _ in pairs(genome2seqs) do
        table.insert(genomes, genome)
    end
    table.sort(genomes)
    return genomes, genome2seqs
end
