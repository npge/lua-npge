-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2016 Boris Nagaev
-- See the LICENSE file for terms of use.

return function(block, genomes_number)
    assert(genomes_number, "Provide number of genomes")
    local config = require 'npge.config'
    local MIN_LENGTH = config.general.MIN_LENGTH
    local isGood = require 'npge.block.isGood'
    local is_good = isGood(block)
    local max_length = 0
    for fragment in block:iterFragments() do
        max_length = math.max(max_length, fragment:length())
    end
    if max_length < MIN_LENGTH and not is_good then
        return "minor"
    end
    if block:size() == 1 then
        return "unique"
    end
    if not is_good then
        return "bad"
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
