-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

local sequence_to_fragment

sequence_to_fragment = function(fragment, sequence_pos)
    local sequence = fragment:sequence()
    assert(sequence_pos >= 0)
    assert(sequence_pos < sequence:length())
    local hasPos = require 'npge.fragment.hasPos'
    assert(hasPos(fragment, sequence_pos))
    if not fragment:parted() then
        local pos_diff = sequence_pos - fragment:start()
        return pos_diff * fragment:ori()
    else
        local a, b = fragment:parts()
        if hasPos(a, sequence_pos) then
            return sequence_to_fragment(a, sequence_pos)
        else
            assert(hasPos(b, sequence_pos))
            local x = sequence_to_fragment(b, sequence_pos)
            return a:length() + x
        end
    end
end

return sequence_to_fragment
