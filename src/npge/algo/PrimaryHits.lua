-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

return function(blockset)
    local BlockSet = require 'npge.model.BlockSet'
    local level2bss = {}
    level2bss[1] = {}

    local Genomes = require 'npge.algo.Genomes'
    local has_genomes, _, genome2seqs = pcall(Genomes, blockset)
    if has_genomes then
        for genome, seqs in pairs(genome2seqs) do
            table.insert(level2bss[1], BlockSet(seqs, {}))
        end
    else
        for seq in blockset:iterSequences() do
            table.insert(level2bss[1], BlockSet({seq}, {}))
        end
    end

    local function popBs()
        for level, bss in ipairs(level2bss) do
            if #bss > 0 then
                return table.remove(bss), level
            end
        end
    end

    local function pushBs(bs, level)
        if not level2bss[level] then
            level2bss[level] = {}
        end
        table.insert(level2bss[level], bs)
    end

    local niterations = #(level2bss[1]) - 1
    for i = 1, niterations do
        local a, level_a = assert(popBs())
        local b, level_b = assert(popBs())
        local Cover = require 'npge.algo.Cover'
        a = Cover(a)
        b = Cover(b)
        local Merge = require 'npge.algo.Merge'
        local HasOverlap = require 'npge.algo.HasOverlap'
        assert(not HasOverlap(Merge {a, b}))
        local AddGoodBlast = require 'npge.algo.AddGoodBlast'
        local hits = AddGoodBlast(a, b)
        local BlocksWithoutOverlaps =
            require 'npge.algo.BlocksWithoutOverlaps'
        hits = BlocksWithoutOverlaps(hits)
        pushBs(hits, math.max(level_a, level_b) + 1)
    end
    local bs = assert(popBs())
    return bs
end
