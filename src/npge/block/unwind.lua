local get_min_max = function(fragment)
    if fragment:ori() == 1 then
        return fragment:start(), fragment:stop()
    else
        return fragment:stop(), fragment:start()
    end
end

return function(block, seqs2blocks)
    local for_block = {}
    for fragment in block:iter_fragments() do
        local seq = fragment:sequence()
        local orig_block = assert(seqs2blocks[seq])
        if fragment:parted() then
            -- unique seq on consensus built on unique seq
            assert(block:size() == 1)
            assert(block:length() == #block:text(fragment))
            assert(orig_block:size() == 1)
            local f = orig_block:fragments()[1]
            assert(orig_block:length() == #orig_block:text(f))
            table.insert(for_block, fragment)
        else
            local row = block:text(fragment)
            if fragment:ori() == -1 then
                local C = require 'npge.alignment.complement'
                row = C(row)
            end
            local min, max = get_min_max(fragment)
            local slice = require 'npge.block.slice'
            local new_block = slice(orig_block, min, max, row)
            if new_block then
                if fragment:ori() == -1 then
                    local reverse = require 'npge.block.reverse'
                    new_block = reverse(new_block)
                end
                for new_f in new_block:iter_fragments() do
                    local new_row = new_block:text(new_f)
                    table.insert(for_block, {new_f, new_row})
                end
            end
        end
    end
    if #for_block == 0 then
        return nil
    end
    local Block = require 'npge.model.Block'
    return Block(for_block)
end
