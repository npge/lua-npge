local makeBuckets = function(workers, blockset)
    local buckets = {}
    for i = 1, workers do
        table.insert(buckets, {})
    end
    local config = require 'npge.config'
    math.randomseed(os.time())
    for block in blockset:iter_blocks() do
        local ibucket = math.random(1, #buckets)
        table.insert(buckets[ibucket], block)
    end
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

local workerCode = [[
    local ref, alg = ...
    local BlockSet = require 'npge.model.BlockSet'
    local decrease_count = true
    local bs = BlockSet.fromRef(ref, decrease_count)
    local algorithm = require(alg)
    bs = assert(algorithm(bs))
    local increase_count = true
    return BlockSet.toRef(bs, increase_count)
]]

local spawnWorker = function(bs, alg)
    local BlockSet = require 'npge.model.BlockSet'
    assert(BlockSet.toRef)
    local increase_count = true
    local ref = BlockSet.toRef(bs, increase_count)
    local llthreads = require "llthreads"
    local thread = llthreads.new(workerCode, ref, alg)
    thread:start()
    return thread
end

local spawnWorkers = function(blocksets, alg)
    local threads = {}
    for _, bs in ipairs(blocksets) do
        local thread =spawnWorker(bs, alg)
        table.insert(threads, thread)
    end
    return threads
end

local collectResult = function(thread)
    local status, result = thread:join()
    if status then
        local BlockSet = require 'npge.model.BlockSet'
        local decrease_count = true
        return BlockSet.fromRef(result, decrease_count)
    else
        print(result)
        return nil
    end
end

local collectResults = function(threads)
    local blocksets = {}
    local error_happened = false
    for _, thread in ipairs(threads) do
        local bs = collectResult(thread)
        if bs then
            table.insert(blocksets, bs)
        else
            error_happened = true
        end
    end
    assert(not error_happened, "One of workers failed")
    local Merge = require 'npge.algo.Merge'
    local unpack = require 'npge.util.unpack'
    return Merge(unpack(blocksets))
end

-- see https://github.com/Neopallium/lua-llthreads
-- alg is algorithm name (example: "npge.algo.GoodSubblocks")
-- algorithm must accept and return a blockset
return function(blockset, alg)
    local algorithm = assert(require(alg))
    local config = require 'npge.config'
    local workers = config.util.WORKERS
    if workers == 1 then
        return algorithm(blockset)
    end
    local blocksets = makeBuckets(workers, blockset)
    local threads = spawnWorkers(blocksets, alg)
    return collectResults(threads)
end
