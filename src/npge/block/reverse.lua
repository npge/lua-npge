return function(block)
    local reverse_fragment = require 'npge.fragment.reverse'
    local for_block = {}
    for fragment in block:iter_fragments() do
        local new_f = reverse_fragment(fragment)
        local row = block:text(fragment)
        local Sequence = require 'npge.model.Sequence'
        local new_row = Sequence.complement(row)
        table.insert(for_block, {new_f, new_row})
    end
    local Block = require 'npge.model.Block'
    return Block(for_block)
end
