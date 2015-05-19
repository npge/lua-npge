-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

local members = {
    'NonCovered',
    'Merge',
    'Subtract',
    'ConsensusSequences',
    'UnwindBlocks',
    'Blast',
    'BlastHits',
    'AddGoodBlast',
    'FilterGoodBlocks',
    'BlocksWithoutOverlaps',
    'GoodSubblocks',
    'BetterSubblocks',
    'Cover',
    'Align',
    'ReAlign',
    'Orient',
    'Join',
    'Extend',
    'Genomes',
    'PrimaryHits',
    'PangenomeMaker',
    'HasOverlap',
    'HasSelfOverlap',
    'ExcludeSelfOverlap',
    'Workers',
    'GiveNames',
    'Overlapping',
    'JoinMinor',
    'CheckPangenome',
}

local algo = {}

for _, member in ipairs(members) do
    algo[member] = require('npge.algo.' .. member)
end

return algo
