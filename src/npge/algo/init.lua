local members = {
    'NonCovered',
    'Merge',
    'ReadSequencesFromFasta',
    'ReadFromBs',
    'ConsensusSequences',
    'UnwindBlocks',
}

local algo = {}

for _, member in ipairs(members) do
    algo[member] = require('npge.algo.' .. member)
end

return algo
