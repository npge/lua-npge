-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2016 Boris Nagaev
-- See the LICENSE file for terms of use.

local function getMinMax(fragment)
    if fragment:ori() == 1 then
        return fragment:start(), fragment:stop()
    else
        return fragment:stop(), fragment:start()
    end
end

local function getBlock(seq_name, prefix2blockset)
    local startsWith = require 'npge.util.startsWith'
    for prefix, blockset in pairs(prefix2blockset) do
        if startsWith(seq_name, prefix) then
            local name = seq_name:sub(#prefix + 1)
            return blockset:blockByName(name)
        end
    end
end

return function(block, prefix2blockset)
    local for_block = {}
    for fragment in block:iterFragments() do
        local seq = fragment:sequence()
        local orig_block = assert(getBlock(seq:name(),
            prefix2blockset), "No block for " .. seq:name())
        assert(not fragment:parted())
        local row = block:text(fragment)
        if fragment:ori() == -1 then
            local C = require 'npge.alignment.complement'
            row = C(row)
        end
        local min, max = getMinMax(fragment)
        local slice = require 'npge.block.slice'
        local new_block = slice(orig_block, min, max, row)
        if new_block then
            if fragment:ori() == -1 then
                local reverse = require 'npge.block.reverse'
                new_block = reverse(new_block)
            end
            for new_f in new_block:iterFragments() do
                local new_row = new_block:text(new_f)
                table.insert(for_block, {new_f, new_row})
            end
        end
    end
    if #for_block == 0 then
        return nil
    end
    local refine = require 'npge.block.refine'
    local Block = require 'npge.model.Block'
    return refine(Block(for_block))
end
