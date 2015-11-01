-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

local function readWithReference(generator, bs1)
    local blockname2fragments = {}
    local ev = require 'npge.util.extractValue'
    local parseId = require 'npge.fragment.parseId'
    for name, description, text in generator do
        local blockname = assert(ev(description, "block"),
            ("No block name found in %q"):format(description))
        local seqname, start, stop, ori = parseId(name)
        if not blockname2fragments[blockname] then
            blockname2fragments[blockname] = {}
        end
        local fr_desc = {seqname, start, stop, ori, text}
        table.insert(blockname2fragments[blockname], fr_desc)
    end
    return bs1:sequences(), blockname2fragments
end

local function makeBlock(bs1, fr_descs)
    local alignment = {}
    local unpack = require 'npge.util.unpack'
    local Fragment = require 'npge.model.Fragment'
    for _, fr_desc in ipairs(fr_descs) do
        local seqname, start, stop, ori, text = unpack(fr_desc)
        local seq = assert(bs1:sequenceByName(seqname))
        local fragment = Fragment(seq, start, stop, ori)
        table.insert(alignment, {fragment, text})
    end
    local Block = require 'npge.model.Block'
    return Block(alignment)
end

return function(lines, blockset_with_sequences)
    -- lines is iterator (like file:lines()) or string
    if type(lines) == 'string' then
        local util = require 'npge.util'
        lines = util.textToIt(lines)
    end
    local bs1 = blockset_with_sequences
    local fromFasta = require 'npge.util.fromFasta'
    local f = readWithReference
    local sequences, blockname2fragments = f(fromFasta(lines), bs1)
    local blocks = {}
    for blockname, fr_descs in pairs(blockname2fragments) do
        local Block = require 'npge.model.Block'
        blocks[blockname] = makeBlock(bs1, fr_descs)
    end
    local BlockSet = require 'npge.model.BlockSet'
    return BlockSet(bs1:sequences(), blocks)
end
