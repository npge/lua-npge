-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2016 Boris Nagaev
-- See the LICENSE file for terms of use.

local function concat(fields)
    return table.concat(fields, '\t') .. '\n'
end

local DOUBLE_FORMAT = "%.4f"

return function(blockset, no_genomes)
    return coroutine.wrap(function()
        local genomes = {}
        if not no_genomes then
            local Genomes = require 'npge.algo.Genomes'
            genomes = Genomes(blockset)
        end
        -- headers
        local headers = {
            'block',
            'size',
            'length',
            'identity',
            'gc',
        }
        for _, genome in ipairs(genomes) do
            table.insert(headers, genome)
        end
        coroutine.yield(concat(headers))
        -- blocks...
        local blockInfo = require 'npge.block.info'
        for block, name in blockset:iterBlocks() do
            local info = blockInfo(block)
            local fields = {
                name,
                info.size,
                info.length,
                DOUBLE_FORMAT:format(info.identity),
                DOUBLE_FORMAT:format(info.gc),
            }
            for _, genome in ipairs(genomes) do
                local count = assert(info.genomes)[genome] or 0
                table.insert(fields, count)
            end
            coroutine.yield(concat(fields))
        end
    end)
end
