-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

return function(block)
    local count = {A=0, T=0, G=0, C=0}
    for fragment in block:iterFragments() do
        local text = fragment:text()
        for i = 1, #text do
            local c = text:sub(i, i)
            count[c] = (count[c] or 0) + 1
        end
    end
    local all = count.A + count.T + count.G + count.C
    local gc = count.G + count.C
    if all == 0 then
        return 0
    else
        return gc / all
    end
end
