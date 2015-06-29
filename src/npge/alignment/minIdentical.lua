-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

-- converts identity as a double to integer (0.9 -> 90)
-- min_identity is rounded to nearest number of %
local MAX_COLUMN_SCORE
return function(min_identity)
    local percents = math.floor(min_identity * 100 + 0.5)
    if not MAX_COLUMN_SCORE then
        local cpp = require 'npge.cpp'
        MAX_COLUMN_SCORE = cpp.alignment.MAX_COLUMN_SCORE
    end
    return math.floor(percents * MAX_COLUMN_SCORE / 100)
end
