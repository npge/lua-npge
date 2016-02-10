-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2016 Boris Nagaev
-- See the LICENSE file for terms of use.

return function(name, description, text)
    local asLines = require 'npge.util.asLines'
    return (">%s %s\n%s\n"):format(name,
        description, asLines(text))
end
