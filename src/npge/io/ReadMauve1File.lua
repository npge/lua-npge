-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2016 Boris Nagaev
-- See the LICENSE file for terms of use.

-- Read XMFA file

local function ReadMauve1File(
    lines,
    blockset_with_sequences,
    sequences_names -- ordered list of sequence names
)
    local trim = require 'npge.util.trim'
    local startsWith = require 'npge.util.startsWith'

    local format = trim(lines())
    assert(format == '#FormatVersion Mauve1')

    local Fragment = require 'npge.model.Fragment'
    local function makeFragment(name, description)
        local seq_index, seq_min, seq_max = assert(
            name:match('(%d+):(%d+)-(%d+)')
        )
        seq_index = assert(tonumber(seq_index))
        seq_min = assert(tonumber(seq_min))
        seq_max = assert(tonumber(seq_max))
        local seq_name = assert(
            sequences_names[seq_index],
            "Bad sequence index: " .. seq_index
        )
        local seq = assert(
            blockset_with_sequences:sequenceByName(seq_name),
            "Unknown sequence name: " .. seq_name
        )
        local ori = startsWith(description, '+') and 1 or -1
        local seq_from, seq_to
        if ori == 1 then
            seq_from, seq_to = seq_min, seq_max
        else
            seq_from, seq_to = seq_max, seq_min
        end
        return Fragment(seq, seq_from - 1, seq_to - 1, ori)
    end

    local new_block = false

    local function linesWithoutHeader()
        while true do
            local line = lines()
            if line and startsWith(line, '=') then
                new_block = true
            elseif not line or not startsWith(line, '#') then
                return line
            end
        end
    end

    local fromFasta = require 'npge.util.fromFasta'
    local Block = require 'npge.model.Block'
    local blocks = {}
    local current_block_data = {}
    for name, description, text in fromFasta(linesWithoutHeader) do
        local fragment = makeFragment(name, description)
        table.insert(current_block_data, {fragment, text})
        if new_block then
            new_block = false
            local block = Block(current_block_data)
            table.insert(blocks, block)
            current_block_data = {}
        end
    end

    local BlockSet = require 'npge.model.BlockSet'
    return BlockSet(
        blockset_with_sequences:sequences(),
        blocks
    )
end

return ReadMauve1File
