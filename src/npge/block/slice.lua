local slice_f = function(fragment, frag_min, frag_max)
    local seq = fragment:sequence()
    local to_sequence =
        require 'npge.fragment.fragment_to_sequence'
    local seq_min = to_sequence(fragment, frag_min)
    local seq_max = to_sequence(fragment, frag_max)
    local ori = fragment:ori()
    local Fragment = require 'npge.model.Fragment'
    return Fragment(seq, seq_min, seq_max, ori)
end

local slice_row = function(row, orig_row)
    local new_row = {}
    local orig_i = 1
    for i = 1, #row do
        local c = row:sub(i, i)
        if c == '-' then
            table.insert(new_row, '-')
        else
            table.insert(new_row, orig_row:sub(orig_i, orig_i))
            orig_i = orig_i + 1
        end
    end
    assert(orig_i == #orig_row + 1)
    return table.concat(new_row)
end

return function(block, min, max, row)
    assert(min <= max)
    if not row then
        local length = max - min + 1
        row = string.rep('N', length)
    end
    assert(#row >= (max - min + 1))
    local for_block = {}
    for fragment in block:iter_fragments() do
        local seq = fragment:sequence()
        local frag_min = block:block2right(fragment, min)
        local frag_max = block:block2left(fragment, max)
        if frag_min ~= -1 and frag_max ~= -1 and
                frag_min <= frag_max then
            local new_f = slice_f(fragment, frag_min, frag_max)
            local orig_row = block:text(fragment)
            orig_row = orig_row:sub(min + 1, max + 1)
            local new_row = slice_row(row, orig_row)
            table.insert(for_block, {new_f, new_row})
        end
    end
    if #for_block == 0 then
        return nil
    end
    local Block = require 'npge.model.Block'
    return Block(for_block)
end
