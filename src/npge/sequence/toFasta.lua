-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

return function(sequence)
    local asLines = require 'npge.util.asLines'
    return (">%s %s\n%s\n"):format(sequence:name(),
        sequence:description(), asLines(sequence:text()))
end
