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
    is_good = require 'npge.block.is_good',
    goodSubblocks = require 'npge.block.goodSubblocks',
    align = require 'npge.block.align',
    extend = require 'npge.block.extend',
}
