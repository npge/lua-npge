local members = {
    'NonCovered',
    'Merge',
}

local algo = {}

for _, member in ipairs(members) do
    algo[member] = require('npge.algo.' .. member)
end

return algo
