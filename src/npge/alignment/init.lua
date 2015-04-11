-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

return {
    left = require 'npge.alignment.left',
    anchor = require 'npge.alignment.anchor',
    to_atgcn = require 'npge.alignment.to_atgcn',
    toAtgcnAndGap = require 'npge.alignment.toAtgcnAndGap',
    unwind_row = require 'npge.alignment.unwind_row',
    complement = require 'npge.alignment.complement',
    complementRows = require 'npge.alignment.complementRows',
    moveIdentical = require 'npge.alignment.moveIdentical',
    join = require 'npge.alignment.join',
    alignRows = require 'npge.alignment.alignRows',
    identity = require 'npge.alignment.identity',
}
