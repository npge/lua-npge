return function(blockset)
    local genomes_set = {}
    for sequence in blockset:iter_sequences() do
        local genome = assert(sequence:genome(),
            ("No genome: %s"):format(sequence:name()))
        genomes_set[genome] = true
    end
    local genomes = {}
    for genome, _ in pairs(genomes_set) do
        table.insert(genomes, genome)
    end
    return genomes
end
