-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

return function(fragment)
    local Fragment = require 'npge.model.Fragment'
    return Fragment(fragment:sequence(),
        fragment:stop(), fragment:start(), -(fragment:ori()))
end
