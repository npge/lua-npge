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

local function isParted(start, stop, ori)
    local diff = stop - start
    return diff * ori < 0
end

local function getParts(seqname, start, stop, ori, text)
    local toAtgcn = require 'npge.alignment.toAtgcn'
    local text = toAtgcn(text)
    local length = #text
    local length1, length2
    if ori == 1 then
        length2 = stop + 1
        length1 = length - length2
    else
        length1 = start + 1
        length2 = length - length1
    end
    local start1 = start
    local stop1 = start1 + (length1 - 1) * ori
    local stop2 = stop
    local start2 = stop2 - (length2 - 1) * ori
    local text1 = text:sub(1, length1)
    local text2 = text:sub(length1 + 1)
    assert(#text1 == length1)
    assert(#text2 == length2)
    assert(start1 >= 0)
    assert(start2 >= 0)
    return {seqname, start1, stop1, ori, text1},
           {seqname, start2, stop2, ori, text2}
end

local function makeSequence(seqname, parts)
    local unpack = require 'npge.util.unpack'
    local parts2 = {}
    for _, part in ipairs(parts) do
        local seqname1, start, stop, ori, text = unpack(part)
        assert(seqname1 == seqname)
        if isParted(start, stop, ori) then
            local part1, part2 =
                getParts(seqname, start, stop, ori, text)
            table.insert(parts2, part1)
            table.insert(parts2, part2)
        else
            table.insert(parts2, part)
        end
    end
    table.sort(parts2, function(part1, part2)
        local seqname1, start1, stop1, ori1 = unpack(part1)
        local seqname2, start2, stop2, ori2 = unpack(part2)
        assert(seqname1 == seqname)
        assert(seqname2 == seqname)
        assert(not isParted(start1, stop1, ori1))
        assert(not isParted(start2, stop2, ori2))
        return math.min(start1, stop1) < math.min(start2, stop2)
    end)
    local toAtgcn = require 'npge.alignment.toAtgcn'
    local complement = require 'npge.alignment.complement'
    local texts = {}
    local last = -1
    for _, part in ipairs(parts2) do
        local _, start, stop, ori, text = unpack(part)
        local first = math.min(start, stop)
        assert(first == last + 1, "The blockset is not a partition")
        if ori == -1 then
            text = complement(text)
        end
        table.insert(texts, toAtgcn(text))
        last = math.max(start, stop)
    end
    local text = table.concat(texts)
    local Sequence = require 'npge.model.Sequence'
    return Sequence(seqname, text)
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
    -- create sequences from seqname2parts
    for seqname, parts in pairs(seqname2parts) do
        assert(not seqname2seq[seqname])
        local seq = makeSequence(seqname, parts)
        seqname2seq[seqname] = seq
        collectgarbage() -- large text
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
