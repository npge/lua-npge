-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2016 Boris Nagaev
-- See the LICENSE file for terms of use.

local Workers = {}

Workers.mapBlocks = function(workers, blockset)
    local mapItems = require 'npge.util.mapItems'
    local buckets = mapItems(workers, blockset:blocks())
    local BlockSet = require 'npge.model.BlockSet'
    local sequences = blockset:sequences()
    local blocksets = {}
    for i = 1, workers do
        local blocks = buckets[i]
        local bs = BlockSet(sequences, blocks)
        table.insert(blocksets, bs)
    end
    return blocksets
end

Workers.mapSequences = function(workers, blockset)
    local mapItems = require 'npge.util.mapItems'
    local buckets = mapItems(workers, blockset:sequences())
    local BlockSet = require 'npge.model.BlockSet'
    local blocksets = {}
    for i = 1, workers do
        local sequences = buckets[i]
        local bs = BlockSet(sequences, {})
        table.insert(blocksets, bs)
    end
    return blocksets
end

local workerCode = [[
local ref = %q
local alg = %q
local BlockSet = require 'npge.model.BlockSet'
local decrease_count = true
local bs = BlockSet.fromRef(ref, decrease_count)
local loadstring = require 'npge.util.loadstring'
local algorithm = loadstring(alg)
bs = assert(algorithm(bs))
local increase_count = true
return BlockSet.toRef(bs, increase_count)
]]

-- Map-reduce for algorithms on blocks.
-- 1. Splits the blockset into buckets using function
--    Workers.mapBlocks or Workers.mapSequences (argument map)
-- 2. apply alg to each bucket in parallel. alg must be a
--    string of Lua code, which gets a bockset and returns
--    a blockset.
Workers.applyToBlockset = function(blockset, alg, map)
    local threads = require 'npge.util.threads'
    return threads(
    -- generator
    function(workers)
        local codes = {}
        local blocksets = map(workers, blockset)
        local BlockSet = require 'npge.model.BlockSet'
        for _, bs in ipairs(blocksets) do
            local increase_count = true
            local ref = BlockSet.toRef(bs, increase_count)
            table.insert(codes, workerCode:format(ref, alg))
        end
        return codes
    end,
    -- collector
    function(results)
        local blocksets = {}
        local BlockSet = require 'npge.model.BlockSet'
        for _, ref in ipairs(results) do
            local decrease_count = true
            local bs = BlockSet.fromRef(ref, decrease_count)
            table.insert(blocksets, bs)
        end
        local Merge = require 'npge.algo.Merge'
        return Merge(blocksets)
    end)
end

Workers.GoodSubblocks = function(blockset)
    local code = [[
        local bs = ...
        local GS = require 'npge.algo.GoodSubblocks'
        return GS(bs)
    ]]
    return Workers.applyToBlockset(blockset, code,
        Workers.mapBlocks)
end

Workers.BlastHits = function(query, bank)
    local BlockSet = require 'npge.model.BlockSet'
    if #query:sequences() == 0 or #bank:sequences() == 0 then
        return BlockSet({}, {})
    end
    local Blast = require 'npge.algo.Blast'
    local tmpName = require 'npge.util.tmpName'
    Blast.checkNoCollisions(query, bank)
    local bank_cons_fname = tmpName()
    Blast.makeConsensus(bank_cons_fname, bank)
    local bank_fname = tmpName()
    Blast.makeBlastDb(bank_fname, bank_cons_fname)
    local code = [[
        local BlockSet = require 'npge.model.BlockSet'
        local query = ...
        local decrease_count = false
        local bank = BlockSet.fromRef(%q, decrease_count)
        local BlastHits = require 'npge.algo.BlastHits'
        return BlastHits(query, bank, {bank_fname=%q})
    ]]
    local increase_count = false
    local hits = Workers.applyToBlockset(query,
        code:format(BlockSet.toRef(bank, increase_count),
            bank_fname), Workers.mapSequences)
    os.remove(bank_cons_fname)
    Blast.bankCleanup(bank_fname)
    return hits
end

Workers.UnwindBlocks = function(consensus_bs, prefix2blockset)
    local BlockSet = require 'npge.model.BlockSet'
    local prefix_pairs = {}
    for prefix, bs in pairs(prefix2blockset) do
        local code = "[%q] = BlockSet.fromRef(%q, false),"
        local increase_count = false
        local ref = BlockSet.toRef(bs, increase_count)
        table.insert(prefix_pairs, code:format(prefix, ref))
    end
    local prefix_pairs_code = table.concat(prefix_pairs)
    local code = [[
        local BlockSet = require 'npge.model.BlockSet'
        local consensus_bs = ...
        local prefix2blockset = {%s}
        local UnwindBlocks = require 'npge.algo.UnwindBlocks'
        return UnwindBlocks(consensus_bs, prefix2blockset)
    ]]
    return Workers.applyToBlockset(consensus_bs,
        code:format(prefix_pairs_code), Workers.mapBlocks)
end

return Workers
