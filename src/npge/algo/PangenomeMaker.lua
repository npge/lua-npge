return function(bs)
    -- input a blockset of good blocks only
    -- output: pangenome (partition, blocks are good or unique,
    --      no new good blocks can be found neither in blast
    --      hits, not in results of joining neighbour blocks)
    local algo = require 'npge.algo'
    bs = algo.GoodSubblocks(bs)
    local bs1
    while not bs1 or bs1 ~= bs do
        if bs1 then
            bs = bs1
        end
        local bs_covered = algo.Cover(bs)
        -- blast
        local hits = algo.BlastHitsUnwound(bs_covered)
        bs1 = algo.BlocksWithoutOverlaps(bs, hits)
        -- join
        local joined = algo.Join(bs1)
        joined = algo.GoodSubblocks(joined)
        bs1 = algo.BlocksWithoutOverlaps(bs1, joined)
    end
    bs = algo.Cover(bs)
    return bs
end
