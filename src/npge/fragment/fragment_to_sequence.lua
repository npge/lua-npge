-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

return function(fragment, fragment_pos)
    assert(fragment_pos >= 0)
    assert(fragment_pos < fragment:length())
    local sp = fragment:start() + fragment_pos * fragment:ori()
    local sequence = fragment:sequence()
    if not fragment:parted() then
        assert(sp >= 0)
        assert(sp < sequence:length())
        return sp
    else
        local fix_position =
            require 'npge.sequence.fix_position'
        return fix_position(sequence, sp)
    end
end
