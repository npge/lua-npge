local members = {
    'NonCovered',
    'Merge',
    'ReadSequencesFromFasta',
    'WriteSequencesToFasta',
    'ReadFromBs',
    'ConsensusSequences',
    'UnwindBlocks',
    'BlastHits',
    'AddGoodBlast',
    'FilterGoodBlocks',
    'BlocksWithoutOverlaps',
    'GoodSubblocks',
    'LoadFromLua',
    'SequencesToLua',
    'BlockSetToLua',
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
