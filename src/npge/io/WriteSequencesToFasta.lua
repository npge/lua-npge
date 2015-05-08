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
            local toFasta = require 'npge.sequence.toFasta'
            return toFasta(seq)
        end
    end
end
