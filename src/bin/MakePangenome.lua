#!/usr/bin/env lua

local npge = require 'npge'
local algo = require 'npge.algo'

local fname = assert(arg[1])
local bs = algo.ReadSequencesFromFasta( io.lines(fname))
local bs = algo.PrimaryHits(bs)
local bs = algo.PangenomeMaker(bs)
for part in algo.BlockSetToLua(bs) do
    io.write(part)
end
