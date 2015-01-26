local members = {
    'NonCovered',
    'Merge',
    'ReadSequencesFromFasta',
    'WriteSequencesToFasta',
    'ReadFromBs',
    'ConsensusSequences',
    'UnwindBlocks',
    'BlastHits',
    'BlastHitsUnwound',
    'FilterGoodBlocks',
    'BlocksWithoutOverlaps',
    'GoodSubblocks',
    'LoadFromLua',
    'Cover',
    'Align',
    'ReAlign',
    'Orient',
    'Join',
    'Genomes',
    'PrimaryHits',
    'PangenomeMaker',
    'HasOverlap',
}

local algo = {}

for _, member in ipairs(members) do
    algo[member] = require('npge.algo.' .. member)
end

return algo
