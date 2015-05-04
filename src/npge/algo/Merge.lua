-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

return function(blocksets)
    assert(blocksets)
    local bs1 = assert(blocksets[1])
    if #blocksets == 1 then
        assert(bs1:type() == 'BlockSet')
        return bs1
    end
    local lists_of_blocks = {}
    local name2seq = {}
    for _, bs in ipairs(blocksets) do
        assert(bs:type() == 'BlockSet')
        table.insert(lists_of_blocks, bs:blocks())
        for seq in bs:iterSequences() do
            name2seq[seq:name()] = seq
        end
    end
    local seqs = {}
    for name, seq in pairs(name2seq) do
        table.insert(seqs, seq)
    end
    local concatArrays = require 'npge.util.concatArrays'
    local unpack = require 'npge.util.unpack'
    local blocks = concatArrays(unpack(lists_of_blocks))
    local BlockSet = require 'npge.model.BlockSet'
    return BlockSet(seqs, blocks)
end
