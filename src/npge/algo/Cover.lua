return function(blockset)
    local algo = require 'npge.algo'
    return algo.Merge(blockset, algo.NonCovered(blockset))
end
