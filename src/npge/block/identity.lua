-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

local mt = {}
mt.__index = mt

mt.__call = function(self, block)
    local rows = {}
    for fragment in block:iterFragments() do
        table.insert(rows, block:text(fragment))
    end
    local identity = require 'npge.alignment.identity'
    return identity(rows)
end

return setmetatable({}, mt)
