return function(consensus_bs, original_bs, seqs2blocks)
    local blocks = {}
    for block in consensus_bs:iter_blocks() do
        local unwind = require 'npge.block.unwind'
        local new_block = unwind(block, seqs2blocks)
        if new_block then
            table.insert(blocks, new_block)
        end
    end
    local BlockSet = require 'npge.model.BlockSet'
    return BlockSet(original_bs:sequences(), blocks)
end
