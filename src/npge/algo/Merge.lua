return function(...)
    local blocksets = {...}
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
        for seq in bs:iter_sequences() do
            name2seq[seq:name()] = seq
        end
    end
    local seqs = {}
    for name, seq in pairs(name2seq) do
        table.insert(seqs, seq)
    end
    local concat_arrays = require 'npge.util.concat_arrays'
    local unpack = require 'npge.util.unpack'
    local blocks = concat_arrays(unpack(lists_of_blocks))
    local BlockSet = require 'npge.model.BlockSet'
    return BlockSet(seqs, blocks)
end
