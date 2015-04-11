-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

local to_atgcn2 = require 'npge.alignment.to_atgcn_and_gap'

return {
    left = require 'npge.alignment.left',
    anchor = require 'npge.alignment.anchor',
    to_atgcn = require 'npge.alignment.to_atgcn',
    to_atgcn_and_gap = to_atgcn2,
    unwind_row = require 'npge.alignment.unwind_row',
    complement = require 'npge.alignment.complement',
    complementRows = require 'npge.alignment.complementRows',
    moveIdentical = require 'npge.alignment.moveIdentical',
    join = require 'npge.alignment.join',
    alignRows = require 'npge.alignment.alignRows',
    identity = require 'npge.alignment.identity',
}
