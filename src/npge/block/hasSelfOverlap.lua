-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2016 Boris Nagaev
-- See the LICENSE file for terms of use.

return function(block)
    local fragments0 = block:fragments()
    local fragments = {}
    for _, fragment in ipairs(fragments0) do
        if not fragment:parted() then
            table.insert(fragments, fragment)
        else
            local a, b = fragment:parts()
            table.insert(fragments, a)
            table.insert(fragments, b)
        end
    end
    table.sort(fragments)
    local prev
    for _, fragment in ipairs(fragments) do
        if prev and prev:common(fragment) > 0 then
            return true
        end
        prev = fragment
    end
    return false
end
