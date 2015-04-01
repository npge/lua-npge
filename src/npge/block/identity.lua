-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

local round = function(x)
    return math.floor(x + 0.5)
end

local mt = {}
mt.__index = mt

mt.__call = function(self, block)
    local rows = {}
    for fragment in block:iter_fragments() do
        table.insert(rows, block:text(fragment))
    end
    local identity = require 'npge.alignment.identity'
    return identity(rows)
end

-- round to 0.001 and compare
local MULTIPLIER = 1000

mt.less = function(a, b)
    return round(a * MULTIPLIER) < round(b * MULTIPLIER)
end

mt.eq = function(a, b)
    return round(a * MULTIPLIER) == round(b * MULTIPLIER)
end

return setmetatable({}, mt)
