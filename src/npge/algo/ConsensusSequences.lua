return function(blockset)
    local seq2block = {}
    local sequences = {}
    for i, block in ipairs(blockset:blocks()) do
        local consensus = require 'npge.block.consensus'
        local text = consensus(block)
        local name = ('consensus%06d'):format(i)
        local Sequence = require 'npge.model.Sequence'
        local seq = Sequence(name, text)
        seq2block[seq] = block
        table.insert(sequences, seq)
    end
    local BlockSet = require 'npge.model.BlockSet'
    return BlockSet(sequences, {}), seq2block
end
