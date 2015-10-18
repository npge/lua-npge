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
    local name, description, text_lines
    local function tryAddSeq()
        if name then
            -- add sequence
            local ev = require 'npge.util.extractValue'
            local parseId = require 'npge.fragment.parseId'
            local blockname = assert(ev(description, "block"))
            local seqname, start, stop, ori = parseId(name)
            local seq = assert(bs1:sequenceByName(seqname))
            local Fragment = require 'npge.model.Fragment'
            local fragment = Fragment(seq, start, stop, ori)
            local text = table.concat(text_lines)
            if not blockname2fragments[blockname] then
                blockname2fragments[blockname] = {}
            end
            table.insert(blockname2fragments[blockname],
                {fragment, text})
            name = nil
            description = nil
            text_lines = nil
        end
    end
    for line in lines do
        if line:sub(1, 1) == '>' then
            tryAddSeq()
            local header = line:sub(2, -1)
            local split = require 'npge.util.split'
            header = split(header, '%s+', 1)
            name = header[1]
            description = header[2]
            text_lines = {}
        elseif #line > 0 then
            assert(name)
            table.insert(text_lines, line)
        end
    end
    -- add last sequence
    tryAddSeq()
    --
    local blocks = {}
    for blockname, fragments in pairs(blockname2fragments) do
        local Block = require 'npge.model.Block'
        table.insert(blocks, Block(fragments))
    end
    local BlockSet = require 'npge.model.BlockSet'
    return BlockSet(bs1:sequences(), blocks)
end
