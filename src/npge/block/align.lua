return function(block)
    if block:size() == 1 then
        return block
    end
    local fragments = {}
    local texts = {}
    for f in block:iter_fragments() do
        table.insert(fragments, f)
        table.insert(texts, f:text())
    end
    local align_rows = require 'npge.alignment.align_rows'
    local rows = align_rows(texts)
    assert(#rows == #fragments)
    local for_block = {}
    for i = 1, #fragments do
        table.insert(for_block, {fragments[i], rows[i]})
    end
    local Block = require 'npge.model.Block'
    return Block(for_block)
end
