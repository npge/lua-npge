-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2016 Boris Nagaev
-- See the LICENSE file for terms of use.

return function(blockset)
    local algo = require 'npge.algo'
    return algo.Merge {blockset, algo.NonCovered(blockset)}
end
