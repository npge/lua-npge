return function(blockset)
    local BlockSet = require 'npge.model.BlockSet'
    local level2bss = {}
    level2bss[1] = {}
    for seq in blockset:iter_sequences() do
        table.insert(level2bss[1], BlockSet({seq}, {}))
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

    local niterations = #blockset:sequences() - 1
    for i = 1, niterations do
        local a, level_a = popBs()
        local b, level_b = popBs()
        local Cover = require 'npge.algo.Cover'
        a = Cover(a)
        b = Cover(b)
        local Merge = require 'npge.algo.Merge'
        local ab = Merge(a, b)
        local BlastHitsUnwound =
            require 'npge.algo.BlastHitsUnwound'
        local hits = BlastHitsUnwound(ab)
        local BlocksWithoutOverlaps =
            require 'npge.algo.BlocksWithoutOverlaps'
        hits = BlocksWithoutOverlaps(hits)
        pushBs(hits, math.max(level_a, level_b) + 1)
    end
    local bs = popBs()
    return bs
end
