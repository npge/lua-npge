return function(blockset)
    local genome2seqs = {}
    for sequence in blockset:iter_sequences() do
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
    return genomes, genome2seqs
end
