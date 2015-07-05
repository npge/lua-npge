-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

return function(block)
    local identity = require 'npge.block.identity'
    local gc = require 'npge.block.gc'
    local info = {}
    info.size = block:size()
    info.length = block:length()
    info.identity = identity(block)
    info.gc = gc(block)
    info.genomes = {}
    for fragment in block:iterFragments() do
        local genome = fragment:sequence():genome()
        if not genome then
            info.genomes = nil
            break
        end
        info.genomes[genome] = (info.genomes[genome] or 0) + 1
    end
    return info
end
