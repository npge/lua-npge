-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2016 Boris Nagaev
-- See the LICENSE file for terms of use.

return function(rows, min_identity, min_length)
    local impl = require 'npge.cpp'.func.goodColumns
    local minIdentical = require 'npge.alignment.minIdentical'
    local ident = min_identity and minIdentical(min_identity)
    return impl(rows, ident, min_length)
end
