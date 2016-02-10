-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2016 Boris Nagaev
-- See the LICENSE file for terms of use.

return function(block, genomes_number)
    local blockType = require 'npge.block.blockType'
    local name = "%s%dx%d"
    local t = blockType(block, genomes_number):sub(1, 1)
    local size = block:size()
    local length = block:length()
    return name:format(t, size, length)
end
