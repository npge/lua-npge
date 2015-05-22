-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

-- return minimum number of identical columns in alignment
-- of length min_length. min_identity is rounded to nearest
-- number of %
return function(min_length, min_identity)
    local percents = math.floor(min_identity * 100 + 0.5)
    local product = percents * min_length
    local min_id = math.floor(product / 100)
    if product % 100 ~= 0 then
        min_id = min_id + 1
    end
    return min_id
end
