return function(bs1, bs2)
    assert(bs1:type() == 'BlockSet')
    assert(bs2:type() == 'BlockSet')
    assert(bs1:same_sequences(bs2))
    local concat_arrays = require 'npge.util.concat_arrays'
    local blocks = concat_arrays(bs1:blocks(), bs2:blocks())
    local BlockSet = require 'npge.model.BlockSet'
    return BlockSet(bs1:sequences(), blocks)
end
