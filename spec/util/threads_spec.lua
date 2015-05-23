-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

local N = 1000

local squaring_code = [[
    local min = %d
    local max = %d
    local sum = 0
    for i = min, max do
        sum = sum + i ^ 2
    end
    return sum
]]

local function generator(workers)
    local codes = {}
    local pack = math.floor(N / workers)
    for i = 0, workers - 1 do
        local min = i * pack
        local max = (i + 1) * pack - 1
        if i == workers - 1 then
            max = N
        end
        table.insert(codes, squaring_code:format(min, max))
    end
    return codes
end

local function collector(results)
    local sum = 0
    for _, n in ipairs(results) do
        sum = sum + n
    end
    return sum
end

local control_sum = 0
for i = 0, N do
    control_sum = control_sum + i ^ 2
end

describe("npge.util.threads", function()
    it("calculates sum of squares of numbers from 1 to 1000",
    function()
        local config = require 'npge.config'
        local revert = config:updateKeys({
            util = {WORKERS = 4},
        })
        --
        local threads = require 'npge.util.threads'
        local sum_of_squares = threads(generator, collector)
        assert.equal(control_sum, sum_of_squares)
        --
        revert()
    end)

    it("works if number of workers is #1",
    function()
        local config = require 'npge.config'
        local revert = config:updateKeys({
            util = {WORKERS = 1},
        })
        --
        local threads = require 'npge.util.threads'
        local sum_of_squares = threads(generator, collector)
        assert.equal(control_sum, sum_of_squares)
        --
        revert()
    end)

    it("copies config to thread's Lua state", function()
        local config = require 'npge.config'
        local revert = config:updateKeys({
            general = {MIN_LENGTH = 200},
            util = {WORKERS = 10},
        })
        --
        local threads = require 'npge.util.threads'
        threads(function(n)
            local code = [[
            local config = require 'npge.config'
            assert(config.general.MIN_LENGTH == 200)
            ]]
            local t = {}
            for i = 1, n do
                table.insert(t, code)
            end
            return t
        end, function() end)
        --
        revert()
    end)
end)
