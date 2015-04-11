-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

local iso = require 'npge.fragment.is_subfragment_of'

return {
    reverse = require 'npge.fragment.reverse',
    has_pos = require 'npge.fragment.has_pos',
    is_subfragment_of = iso, -- FIXME
    subfragment = require 'npge.fragment.subfragment',
    sub = require 'npge.fragment.sub',
    sequence_to_fragment = require 'npge.fragment.sequence_to_fragment',
    fragmentToSequence = require 'npge.fragment.fragmentToSequence',
}
