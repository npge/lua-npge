-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

return function(block, genomes_number)
    assert(genomes_number, "Provide number of genomes")
    local config = require 'npge.config'
    if block:length() < config.general.MIN_LENGTH then
        return "minor"
    end
    if block:size() == 1 then
        return "unique"
    end
    local isGood = require 'npge.block.isGood'
    if not isGood(block) then
        return "minor"
    end
    local hasRepeats = require 'npge.block.hasRepeats'
    if hasRepeats(block) then
        return "repeat"
    end
    local genomes = require 'npge.block.genomes'
    if #(genomes(block)) == genomes_number then
        return "stable"
    end
    return "half"
end
