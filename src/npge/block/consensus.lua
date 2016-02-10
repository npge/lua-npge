-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2016 Boris Nagaev
-- See the LICENSE file for terms of use.

return function(block)
    local rows = {}
    for fragment in block:iterFragments() do
        table.insert(rows, block:text(fragment))
    end
    local consensus = require 'npge.alignment.consensus'
    return consensus(rows)
end
