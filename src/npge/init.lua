-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2016 Boris Nagaev
-- See the LICENSE file for terms of use.

return {
    config = require 'npge.config',
    util = require 'npge.util',
    model = require 'npge.model',
    sequence = require 'npge.sequence',
    fragment = require 'npge.fragment',
    block = require 'npge.block',
    alignment = require 'npge.alignment',
    algo = require 'npge.algo',
    io = require 'npge.io',
    view = require 'npge.view',
}
