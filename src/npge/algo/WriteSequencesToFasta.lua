-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

-- returns output file "reading" iterator
return function(blockset)
    local it, t, index = ipairs(blockset:sequences())
    local seq
    return function()
        index, seq = it(t, index)
        if seq then
            local to_fasta = require 'npge.sequence.to_fasta'
            return to_fasta(seq)
        end
    end
end
