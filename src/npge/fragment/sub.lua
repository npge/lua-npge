-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

return function(self, start, stop, ori)
    local subfragment = require 'npge.fragment.subfragment'
    return subfragment(self, start, stop, ori):text()
end
