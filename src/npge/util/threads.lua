-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

-- see https://github.com/moteus/lua-llthreads2
-- WARNING target executable must be linked against pthread
-- Otherwise memory errors occur
-- LD_PRELOAD=/lib/x86_64-linux-gnu/libpthread.so.0 lua ...

local workerCode = [[
local config = require 'npge.config'
config:load(%q)
return xpcall(function()
    %s
end, function(message)
    return message .. '\n' .. debug.traceback()
end)
]]

local spawnWorkers = function(generator, workers, conf)
    local llthreads2 = require "llthreads2"
    local threads = {}
    for _, code in ipairs(generator(workers)) do
        local code1 = workerCode:format(conf, code)
        local thread = llthreads2.new(code1)
        thread:start()
        table.insert(threads, thread)
    end
    return threads
end

local collectResults = function(collector, threads)
    local errors = {}
    local results = {}
    for _, thread in ipairs(threads) do
        local _, status, result = thread:join()
        if status then
            -- if result is nil, do table.insert does nothing
            table.insert(results, result)
        else
            table.insert(errors, result)
        end
    end
    assert(#errors == 0, "Errors in threads: " ..
        table.concat(errors, "\n"))
    return collector(results)
end

-- run an action with threads.
-- Arguments:
-- - generator is a function, which gets number of threads and
--   returns an array of codes to be run in threads.
-- - collector is a function, which gets an array of results
--   threads one after another, and returns final result,
--   which is returned from this function.
return function(generator, collector)
    local config = require 'npge.config'
    local workers = config.util.WORKERS
    local has_llthreads2 = pcall(require, "llthreads2")
    if workers == 1 or not has_llthreads2 then
        local loadstring = require 'npge.util.loadstring'
        local code = generator(1)[1]
        local result = loadstring(code)()
        return collector({result})
    end
    local config = require 'npge.config'
    local conf = config:save()
    local threads = spawnWorkers(generator, workers, conf)
    return collectResults(collector, threads)
end
