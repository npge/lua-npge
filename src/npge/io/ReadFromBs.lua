-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

return function(lines, blockset_with_sequences)
    -- lines is iterator (like file:lines()) or string
    if type(lines) == 'string' then
        local util = require 'npge.util'
        lines = util.textToIt(lines)
    end
    local bs1 = blockset_with_sequences
    local blockname2fragments = {}
    local fromFasta = require 'npge.util.fromFasta'
    local ev = require 'npge.util.extractValue'
    local parseId = require 'npge.fragment.parseId'
    local Fragment = require 'npge.model.Fragment'
    for name, description, text in fromFasta(lines) do
        local blockname = assert(ev(description, "block"))
        local seqname, start, stop, ori = parseId(name)
        local seq = assert(bs1:sequenceByName(seqname))
        local fragment = Fragment(seq, start, stop, ori)
        if not blockname2fragments[blockname] then
            blockname2fragments[blockname] = {}
        end
        table.insert(blockname2fragments[blockname],
            {fragment, text})
    end
    local blocks = {}
    for blockname, fragments in pairs(blockname2fragments) do
        local Block = require 'npge.model.Block'
        blocks[blockname] = Block(fragments)
    end
    local BlockSet = require 'npge.model.BlockSet'
    return BlockSet(bs1:sequences(), blocks)
end
