-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2016 Boris Nagaev
-- See the LICENSE file for terms of use.

return function(block)
    local Block = require 'npge.model.Block'
    return Block(block:fragments())
end
