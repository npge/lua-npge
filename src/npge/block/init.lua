-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

return {
    identity = require 'npge.block.identity',
    consensus = require 'npge.block.consensus',
    reverse = require 'npge.block.reverse',
    orient = require 'npge.block.orient',
    slice = require 'npge.block.slice',
    unwind = require 'npge.block.unwind',
    isGood = require 'npge.block.isGood',
    goodSubblocks = require 'npge.block.goodSubblocks',
    align = require 'npge.block.align',
    extend = require 'npge.block.extend',
    hasSelfOverlap = require 'npge.block.hasSelfOverlap',
    excludeSelfOverlap = require 'npge.block.excludeSelfOverlap',
    hasRepeats = require 'npge.block.hasRepeats',
    genomes = require 'npge.block.genomes',
    blockType = require 'npge.block.blockType',
    giveName = require 'npge.block.giveName',
    parseName = require 'npge.block.parseName',
    hitName = require 'npge.block.hitName',
    better = require 'npge.block.better',
}
