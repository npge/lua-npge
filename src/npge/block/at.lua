return function(self, fragment, blockpos)
    local row = self._fragments[fragment]
    assert(row)
    local fragmentpos = row:block2fragment(blockpos)
    if fragmentpos ~= -1 then
        local fragment_at = require 'npge.fragment.at'
        return fragment_at(fragment, fragmentpos)
    else
        return '-'
    end
end

