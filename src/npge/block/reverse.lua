-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

return function(block)
    local reverse_fragment = require 'npge.fragment.reverse'
    local for_block = {}
    for fragment in block:iter_fragments() do
        local new_f = reverse_fragment(fragment)
        local row = block:text(fragment)
        local C = require 'npge.alignment.complement'
        local new_row = C(row)
        table.insert(for_block, {new_f, new_row})
    end
    local Block = require 'npge.model.Block'
    return Block(for_block)
end
