-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

return function(lines)
    local sequences = {}
    local fromFasta = require 'npge.util.fromFasta'
    local Sequence = require 'npge.model.Sequence'
    for name, description, text in fromFasta(lines) do
        local seq = Sequence(name, text, description)
        table.insert(sequences, seq)
    end
    local BlockSet = require 'npge.model.BlockSet'
    return BlockSet(sequences, {})
end
