-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2016 Boris Nagaev
-- See the LICENSE file for terms of use.

-- TODO avoid copy-paste with npge.alignment.refine
return function(block)
    local rows = {}
    local for_block = {}
    for f in block:iterFragments() do
        local row = block:text(f)
        table.insert(rows, row)
        table.insert(for_block, {f, row})
    end
    local alignment = require 'npge.alignment'
    rows = alignment.removePureGaps(rows)
    for i = 1, #rows do
        for_block[i][2] = rows[i]
    end
    local Block = require 'npge.model.Block'
    return Block(for_block)
end
