-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

return function(block)
    local isAlignedToLeft = require 'npge.block.isAlignedToLeft'
    for fragment in block:iterFragments() do
        if not isAlignedToLeft(fragment, block) then
            return false
        end
    end
    return true
end
