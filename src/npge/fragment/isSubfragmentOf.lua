-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

return function(self, source)
    assert(self:sequence() == source:sequence())
    local overlaps = require 'npge.fragment.overlaps'
    local o = overlaps(self, source)
    local length = 0
    for _, f in ipairs(o) do
        length = length + f:length()
    end
    return length == self:length()
end
