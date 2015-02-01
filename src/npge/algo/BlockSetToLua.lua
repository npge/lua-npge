local seq_to_lua = function(seq)
    local as_lines = require 'npge.util.as_lines'
    local text = as_lines(seq:text())
    local lua = "Sequence(%q,\n%q,\n%q)"
    return lua:format(seq:name(), text, seq:description())
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

local preamble = [[do
    local Sequence = require 'npge.model.Sequence'
    local Fragment = require 'npge.model.Fragment'
    local Block = require 'npge.model.Block'
    local BlockSet = require 'npge.model.BlockSet'
    local name2seq = {}
    local blocks = {}
]]

local closing = [[
    local seqs = {}
    for name, seq in pairs(name2seq) do
        table.insert(seqs, seq)
    end
    return BlockSet(seqs, blocks)
end]]

return function(blockset, has_sequences)
    local wrap, yield = coroutine.wrap, coroutine.yield
    return wrap(function()
        yield(preamble)
        if has_sequences then
            yield("name2seq = ...\n")
        else
            for seq in blockset:iter_sequences() do
                local text = "name2seq[%q] = %s\n"
                yield(text:format(seq:name(), seq_to_lua(seq)))
            end
        end
        for block in blockset:iter_blocks() do
            local text = "table.insert(blocks, %s)\n"
            yield(text:format(block_to_lua(block)))
        end
        yield(closing)
    end)
end
