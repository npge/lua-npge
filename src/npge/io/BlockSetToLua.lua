-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2016 Boris Nagaev
-- See the LICENSE file for terms of use.

local function seqToLua(seq)
    local asLines = require 'npge.util.asLines'
    local text = asLines(seq:text())
    local lua = "Sequence(%q,\n%q,\n%q)"
    return lua:format(seq:name(), text, seq:description())
end

local function fragmentToLua(fragment)
    local lua = "Fragment(name2seq[%q], %i, %i, %i)"
    return lua:format(fragment:sequence():name(),
        fragment:start(), fragment:stop(), fragment:ori())
end

local function blockToLua(block)
    local asLines = require 'npge.util.asLines'
    local areLeft = require 'npge.block.areAlignedToLeft'
    local ff = {}
    local aligned_left = areLeft(block)
    for fragment in block:iterFragments() do
        local fragment_str = fragmentToLua(fragment)
        if aligned_left then
            table.insert(ff, fragment_str)
        else
            local text = block:text(fragment)
            text = asLines(text)
            local lua = "{%s,\n%q}"
            table.insert(ff, lua:format(fragment_str, text))
        end
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
            yield("local names = {\n")
            for seq in blockset:iterSequences() do
                local text = " %q,\n"
                yield(text:format(seq:name()))
            end
            yield("}")
            local text = [[
            local seqs_bs = ...
            for _, name in ipairs(names) do
                local s = seqs_bs:sequenceByName(name)
                name2seq[name] = assert(s)
            end
            ]]
            yield(text)
        else
            for seq in blockset:iterSequences() do
                local text = "name2seq[%q] = %s\n"
                yield(text:format(seq:name(), seqToLua(seq)))
            end
        end
        for block, name in blockset:iterBlocks() do
            local text = "blocks[%q] = %s\n"
            yield(text:format(name, blockToLua(block)))
        end
        yield(closing)
    end)
end
