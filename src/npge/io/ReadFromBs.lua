-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

local function insertFragment(
    blockname2fragments,
    name,
    blockname,
    text
)
    local parseId = require 'npge.fragment.parseId'
    local seqname, start, stop, ori = parseId(name)
    if not blockname2fragments[blockname] then
        blockname2fragments[blockname] = {}
    end
    local fr_desc = {seqname, start, stop, ori, text}
    table.insert(blockname2fragments[blockname], fr_desc)
    return fr_desc
end

local function readWithReference(bs1)
    return function(generator)
        local blockname2fragments = {}
        local ev = require 'npge.util.extractValue'
        for name, description, text in generator do
            local blockname = ev(description, "block")
            if blockname then
                insertFragment(blockname2fragments,
                    name, blockname, text)
            end
        end
        return bs1:sequences(), blockname2fragments
    end
end

local function readWithoutReference(generator)
    local blockname2fragments = {}
    local seqname2seq = {}
    local seqname2parts = {}
    local ev = require 'npge.util.extractValue'
    local Sequence = require 'npge.model.Sequence'
    local parseId = require 'npge.fragment.parseId'
    for name, description, text in generator do
        local blockname = ev(description, "block")
        if blockname then
            -- fragment
            local fr_desc =
                insertFragment(blockname2fragments,
                name, blockname, text)
            local seqname = fr_desc[1] -- insertFragment
            if not seqname2seq[seqname] then
                if not seqname2parts[seqname] then
                    seqname2parts[seqname] = {}
                end
                table.insert(seqname2parts[seqname], fr_desc)
            end
        else
            -- sequence
            local seq = Sequence(name, text, description)
            assert(not seqname2seq[name])
            seqname2seq[name] = seq
            -- remove useless records from seqname2parts
            seqname2parts[name] = nil
        end
    end
    local sequences = {}
    for name, seq in pairs(seqname2seq) do
        table.insert(sequences, seq)
    end
    return sequences, blockname2fragments
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
    local fromFasta = require 'npge.util.fromFasta'
    local f
    if blockset_with_sequences then
        f = readWithReference(blockset_with_sequences)
    else
        f = readWithoutReference
    end
    local sequences, blockname2fragments = f(fromFasta(lines))
    local BlockSet = require 'npge.model.BlockSet'
    local bs1 = BlockSet(sequences, {})
    local blocks = {}
    for blockname, fr_descs in pairs(blockname2fragments) do
        local Block = require 'npge.model.Block'
        blocks[blockname] = makeBlock(bs1, fr_descs)
    end
    return BlockSet(sequences, blocks)
end
