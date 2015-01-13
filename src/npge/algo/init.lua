local members = {
    'NonCovered',
    'Merge',
    'ReadSequencesFromFasta',
    'WriteSequencesToFasta',
    'ReadFromBs',
    'ConsensusSequences',
    'UnwindBlocks',
    'BlastHits',
    'FilterGoodBlocks',
}

local algo = {}

for _, member in ipairs(members) do
    algo[member] = require('npge.algo.' .. member)
end

return algo
