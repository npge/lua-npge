-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2016 Boris Nagaev
-- See the LICENSE file for terms of use.

return {
    left = require 'npge.alignment.left',
    anchor = require 'npge.alignment.anchor',
    toAtgcn = require 'npge.alignment.toAtgcn',
    toAtgcnAndGap = require 'npge.alignment.toAtgcnAndGap',
    unwindRow = require 'npge.alignment.unwindRow',
    complement = require 'npge.alignment.complement',
    complementRows = require 'npge.alignment.complementRows',
    moveIdentical = require 'npge.alignment.moveIdentical',
    join = require 'npge.alignment.join',
    alignRows = require 'npge.alignment.alignRows',
    refine = require 'npge.alignment.refine',
    removePureGaps = require 'npge.alignment.removePureGaps',
    identity = require 'npge.alignment.identity',
    consensus = require 'npge.alignment.consensus',
    goodSlices = require 'npge.alignment.goodSlices',
    goodColumns = require 'npge.alignment.goodColumns',
    minIdentical = require 'npge.alignment.minIdentical',
}
