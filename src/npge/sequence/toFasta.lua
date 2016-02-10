-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2016 Boris Nagaev
-- See the LICENSE file for terms of use.

return function(sequence)
    local toFasta = require 'npge.util.toFasta'
    return toFasta(sequence:name(),
        sequence:description(),
        sequence:text())
end
