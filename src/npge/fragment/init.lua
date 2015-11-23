-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

local iso = require 'npge.fragment.isSubfragmentOf'

return {
    reverse = require 'npge.fragment.reverse',
    hasPos = require 'npge.fragment.hasPos',
    isSubfragmentOf = iso, -- FIXME
    subfragment = require 'npge.fragment.subfragment',
    sub = require 'npge.fragment.sub',
    sequenceToFragment = require 'npge.fragment.sequenceToFragment',
    fragmentToSequence = require 'npge.fragment.fragmentToSequence',
    parseId = require 'npge.fragment.parseId',
    exclude = require 'npge.fragment.exclude',
    overlaps = require 'npge.fragment.overlaps',
}
