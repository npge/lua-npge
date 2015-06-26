-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

local members = {
    'ReadSequencesFromFasta',
    'WriteSequencesToFasta',
    'ReadFromBs',
    'LoadFromLua',
    'BlockSetToLua',
    'ShortForm',
    'ToDot',
}

local npge_io = {}

for _, member in ipairs(members) do
    npge_io[member] = require('npge.io.' .. member)
end

return npge_io
