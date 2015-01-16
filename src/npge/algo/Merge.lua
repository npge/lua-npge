return function(...)
    local blocksets = {...}
    local bs1 = blocksets[1]
    for _, bs in ipairs(blocksets) do
        assert(bs:type() == 'BlockSet')
        assert(bs:same_sequences(bs1))
    end
    local lists_of_blocks = {}
    for _, bs in ipairs(blocksets) do
        table.insert(lists_of_blocks, bs:blocks())
    end
    local concat_arrays = require 'npge.util.concat_arrays'
    local unpack = require 'npge.util.unpack'
    local blocks = concat_arrays(unpack(lists_of_blocks))
    local BlockSet = require 'npge.model.BlockSet'
    return BlockSet(bs1:sequences(), blocks)
end
