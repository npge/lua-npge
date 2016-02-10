-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2016 Boris Nagaev
-- See the LICENSE file for terms of use.

local sequenceToFragment

sequenceToFragment = function(fragment, sequence_pos)
    local sequence = fragment:sequence()
    assert(sequence_pos >= 0)
    assert(sequence_pos < sequence:length())
    local hasPos = require 'npge.fragment.hasPos'
    assert(hasPos(fragment, sequence_pos))
    if not fragment:parted() then
        local pos_diff = sequence_pos - fragment:start()
        return math.abs(pos_diff * fragment:ori())
        -- math.abs to prevent -0
    else
        local a, b = fragment:parts()
        if hasPos(a, sequence_pos) then
            return sequenceToFragment(a, sequence_pos)
        else
            assert(hasPos(b, sequence_pos))
            local x = sequenceToFragment(b, sequence_pos)
            return a:length() + x
        end
    end
end

return sequenceToFragment
