-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

local max = function(fragment)
    assert(not fragment:parted())
    return math.max(fragment:start(), fragment:stop())
end

local min = function(fragment)
    assert(not fragment:parted())
    return math.min(fragment:start(), fragment:stop())
end

return function(blockset)
    local blocks = {}
    for seq in blockset:iterSequences() do
        local F = require 'npge.model.Fragment'
        local fragments = {}
        local last_pos = seq:length() - 1
        local prev
        for fragment, part in blockset:iterFragments(seq) do
            local last = prev and max(prev) or -1
            local first = min(part)
            if first - last > 1 then
                local f = F(seq, last + 1, first - 1, 1)
                table.insert(fragments, f)
            end
            prev = part
        end
        if not prev then
            -- whole sequence
            local f = F(seq, 0, last_pos, 1)
            table.insert(fragments, f)
        elseif max(prev) < last_pos then
            -- 3' uncovered
            local f = F(seq, max(prev) + 1, last_pos, 1)
            table.insert(fragments, f)
        end
        if #fragments >= 2 and seq:circular() then
            -- join first and last into one parted fragment
            local f1 = fragments[1]
            local fn = fragments[#fragments]
            if f1:start() == 0 and fn:stop() == last_pos then
                local sum = F(seq, fn:start(), f1:stop(), 1)
                fragments[1] = sum -- replace f1 with sum
                table.remove(fragments) -- removes fn
            end
        end
        local Block = require 'npge.model.Block'
        for _, fragment in ipairs(fragments) do
            table.insert(blocks, Block({fragment}))
        end
    end
    local BlockSet = require 'npge.model.BlockSet'
    return BlockSet(blockset:sequences(), blocks)
end
