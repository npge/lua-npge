-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2016 Boris Nagaev
-- See the LICENSE file for terms of use.

return function(fragment, block)
    local last_pos = fragment:length() - 1
    return block:fragment2block(fragment, last_pos) == last_pos
end
