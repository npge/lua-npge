-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2016 Boris Nagaev
-- See the LICENSE file for terms of use.

-- Read file bbcols file

local function ReadMauveBbcolsFile(
    lines,
    mauve_global_blocks,
    sequences_names -- ordered list of sequence names
)

    local slice = require 'npge.block.slice'
    local Block = require 'npge.model.Block'
    local function makeConservedBlock(fields)
        -- get global block
        local global_block_index = fields[1]
        local global_block = mauve_global_blocks:blockByName(
            tostring(global_block_index + 1)
        )
        -- get needed sequences
        local needed_names_set = {}
        for i = 4, #fields do
            local sequence_index = fields[i]
            local seq_name = assert(sequences_names[sequence_index + 1],
                "Bad sequence index: " .. sequence_index)
            needed_names_set[seq_name] = true
        end
        local needed_rows = {}
        for fragment in global_block:iterFragments() do
            local seq_name = fragment:sequence():name()
            if needed_names_set[seq_name] then
                local text = global_block:text(fragment)
                table.insert(needed_rows, {fragment, text})
            end
        end
        local needed_rows_block = Block(needed_rows)
        -- get needed columns
        local global_block_start = fields[2]
        local global_block_length = fields[3]
        local min = global_block_start - 1
        local max = min + global_block_length - 1
        return slice(needed_rows_block, min, max)
    end

    local trim = require 'npge.util.trim'
    local split = require 'npge.util.split'
    local conserved_blocks = {}
    for line in lines do
        line = trim(line)
        local fields = split(line, '\t')
        for i = 1, #fields do
            fields[i] = tonumber(fields[i])
        end
        local conserved_block = makeConservedBlock(fields)
        table.insert(conserved_blocks, conserved_block)
    end

    local BlockSet = require 'npge.model.BlockSet'
    return BlockSet(
        mauve_global_blocks:sequences(),
        conserved_blocks
    )
end

return ReadMauveBbcolsFile
