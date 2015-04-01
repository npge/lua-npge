-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

return function(lines)
    -- lines is iterator (like file:lines())
    local sequences = {}
    local name, description, text_lines
    local try_add_seq = function()
        if name then
            -- add sequence
            local text = table.concat(text_lines)
            local Sequence = require 'npge.model.Sequence'
            local seq = Sequence(name, text, description)
            table.insert(sequences, seq)
            name = nil
            description = nil
            text_lines = nil
        end
    end
    for line in lines do
        if line:sub(1, 1) == '>' then
            try_add_seq()
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
    try_add_seq()
    local BlockSet = require 'npge.model.BlockSet'
    return BlockSet(sequences, {})
end
