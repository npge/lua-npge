-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

describe("npge.algo.Genomes", function()
    it("gets a list of genomes of a blockset", function()
        local model = require 'npge.model'
        local bs = model.BlockSet({
            model.Sequence("genome1&chr1&c", "ATAT"),
            model.Sequence("genome2&chr1&c", "ATAT"),
        }, {})
        local Genomes = require 'npge.algo.Genomes'
        local gg1 = Genomes(bs)
        local gg2 = {'genome1', 'genome2'}
        assert.same(gg1, gg2)
    end)

    it("gets a dict from genome to list of sequences",
    function()
        local model = require 'npge.model'
        local s1 = model.Sequence("genome1&chr1&c", "ATAT")
        local s2 = model.Sequence("genome2&chr1&c", "ATAT")
        local bs = model.BlockSet({s1, s2}, {})
        local Genomes = require 'npge.algo.Genomes'
        local list, dict = Genomes(bs)
        assert.same(dict, {genome1={s1}, genome2={s2}})
    end)

    it("throws if sequence name does not contain genome",
    function()
        assert.has_error(function()
            local model = require 'npge.model'
            local bs = model.BlockSet({
                model.Sequence("genome1chr1c", "ATAT"),
                model.Sequence("genome2chr1c", "ATAT"),
            }, {})
            local Genomes = require 'npge.algo.Genomes'
            local gg1 = Genomes(bs)
        end)
    end)
end)
