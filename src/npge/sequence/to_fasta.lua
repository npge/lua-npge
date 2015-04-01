-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

return function(sequence)
    local as_lines = require 'npge.util.as_lines'
    return (">%s %s\n%s\n"):format(sequence:name(),
        sequence:description(), as_lines(sequence:text()))
end
