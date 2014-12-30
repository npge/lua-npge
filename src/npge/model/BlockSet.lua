
local BlockSet = {}
local BlockSet_mt = {}
local bs_mt = {}

BlockSet_mt.__index = BlockSet_mt
bs_mt.__index = bs_mt

BlockSet_mt.__call = function(self, sequences, blocks)
    local name2seq = {}
    for _, sequence in ipairs(sequences) do
        assert(sequence:type() == 'Sequence')
        assert(not name2seq[sequence:name()])
        name2seq[sequence:name()] = sequence
    end
    for _, block in ipairs(blocks) do
        for fragment in block:iter_fragments() do
            local seq = fragment:seq()
            local name = seq:name()
            assert(name2seq[name])
        end
    end
    local bs = {_name2seq=name2seq, _blocks=blocks}
    return setmetatable(bs, bs_mt)
end

bs_mt.size = function(self)
    return #(self._blocks)
end

bs_mt.blocks = function(self)
    local blocks = {}
    for _, block in ipairs(self._blocks) do
        table.insert(blocks, block)
    end
    return blocks
end

bs_mt.iter_blocks = function(self)
    local index, block
    return function()
        index, block = next(self._blocks, index)
        return block
    end
end

bs_mt.seqs = function(self)
    local seqs = {}
    for name, seq in pairs(self._name2seq) do
        table.insert(seqs, seq)
    end
    return seqs
end

bs_mt.iter_seqs = function(self)
    local name, seq
    return function()
        name, seq = next(self._name2seq, name)
        return seq
    end
end

return setmetatable(BlockSet, BlockSet_mt)

