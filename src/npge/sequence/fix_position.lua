-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

return function(seq, x)
    if x < 0 then
        assert(seq:circular())
        return x + seq:length()
    elseif x >= seq:length() then
        assert(seq:circular())
        return x - seq:length()
    else
        return x
    end
end
