local members = {
    'NonCovered',
    'Merge',
    'ReadSequencesFromFasta',
}

local algo = {}

for _, member in ipairs(members) do
    algo[member] = require('npge.algo.' .. member)
end

return algo
