local seq_to_lua = function(seq)
    local as_lines = require 'npge.util.as_lines'
    local text = as_lines(seq:text())
    local lua = "Sequence(%q,\n%q,\n%q)"
    return lua:format(seq:name(), text, seq:description())
end

local seqs_to_lua = function(seqs)
    local seqs_list = {}
    for _, seq in ipairs(seqs) do
        local lua = "[%q] =\n%s"
        lua = lua:format(seq:name(), seq_to_lua(seq))
        table.insert(seqs_list, lua)
    end
    local seqs_str = table.concat(seqs_list, ',\n')
    return ("{%s}"):format(seqs_str)
end

local fragment_to_lua = function(fragment)
    local lua = "Fragment(name2seq[%q], %i, %i, %i)"
    return lua:format(fragment:sequence():name(),
        fragment:start(), fragment:stop(), fragment:ori())
end

local block_to_lua = function(block)
    local as_lines = require 'npge.util.as_lines'
    local ff = {}
    for fragment in block:iter_fragments() do
        local text = block:text(fragment)
        text = as_lines(text)
        local fragment_str = fragment_to_lua(fragment)
        local lua = "{%s,\n%q}"
        table.insert(ff, lua:format(fragment_str, text))
    end
    ff = table.concat(ff, ',\n')
    local lua = "(function() return Block({%s}) end)()"
    return lua:format(ff)
end

local blocks_to_lua = function(blocks)
    local blocks_list = {}
    for _, block in ipairs(blocks) do
        table.insert(blocks_list, block_to_lua(block))
    end
    local blocks_str = table.concat(blocks_list, ',\n')
    return ("{%s}"):format(blocks_str)
end

local lua = [[do
    local Sequence = require 'npge.model.Sequence'
    local Fragment = require 'npge.model.Fragment'
    local Block = require 'npge.model.Block'
    local BlockSet = require 'npge.model.BlockSet'
    local name2seq = %s
    local blocks = %s
    local seqs = {}
    for name, seq in pairs(name2seq) do
        table.insert(seqs, seq)
    end
    return BlockSet(seqs, blocks)
end]]

return function(blockset)
    return lua:format(
        seqs_to_lua(blockset:sequences()),
        blocks_to_lua(blockset:blocks()))
end
