-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

describe("npge.algo.Join", function()
    it("joins consequent blocks",
    function()
        local model = require 'npge.model'
        local s1 = model.Sequence('s1', "ATGC")
        local s2 = model.Sequence('s2', "ATGC")
        local blockset = model.BlockSet({s1, s2}, {
            model.Block({
                model.Fragment(s1, 0, 1, 1),
                model.Fragment(s2, 0, 1, 1),
            }),
            model.Block({
                model.Fragment(s1, 2, 3, 1),
                model.Fragment(s2, 2, 3, 1),
            }),
        })
        --
        local Join = require 'npge.algo.Join'
        local blockset_joined = Join(blockset)
        local BWO = require 'npge.algo.BlocksWithoutOverlaps'
        blockset_joined = BWO(blockset_joined)
        local Orient = require 'npge.algo.Orient'
        blockset_joined = Orient(blockset_joined)
        assert.equal(blockset_joined,
            model.BlockSet({s1, s2}, {
                model.Block({
                    model.Fragment(s1, 0, 3, 1),
                    model.Fragment(s2, 0, 3, 1),
                }),
            }))
    end)

    it("joins consequent blocks (smallest block between)",
    function()
        local model = require 'npge.model'
        local s1 = model.Sequence('s1', "ATGC")
        local s2 = model.Sequence('s2', "ATGC")
        local blockset = model.BlockSet({s1, s2}, {
            model.Block({
                model.Fragment(s1, 0, 0, 1),
                model.Fragment(s2, 0, 0, 1),
            }),
            model.Block({
                model.Fragment(s1, 3, 3, 1),
                model.Fragment(s2, 3, 3, 1),
            }),
            model.Block({
                model.Fragment(s1, 1, 2, 1),
            }),
        })
        --
        local Join = require 'npge.algo.Join'
        local blockset_joined = Join(blockset)
        local BWO = require 'npge.algo.BlocksWithoutOverlaps'
        blockset_joined = BWO(blockset_joined)
        local Orient = require 'npge.algo.Orient'
        blockset_joined = Orient(blockset_joined)
        assert.equal(blockset_joined,
            model.BlockSet({s1, s2}, {
                model.Block({
                    model.Fragment(s1, 0, 3, 1),
                    model.Fragment(s2, 0, 3, 1),
                }),
            }))
    end)

    it("joins consequent blocks (bad orientation)",
    function()
        local model = require 'npge.model'
        local s1 = model.Sequence('s1', "ATGC")
        local s2 = model.Sequence('s2', "ATGC")
        local blockset = model.BlockSet({s1, s2}, {
            model.Block({
                model.Fragment(s1, 0, 1, 1),
                model.Fragment(s2, 0, 1, 1),
            }),
            model.Block({
                model.Fragment(s1, 2, 3, 1),
                model.Fragment(s2, 3, 2, -1),
            }),
        })
        --
        local Join = require 'npge.algo.Join'
        local blockset_joined = Join(blockset)
        local BWO = require 'npge.algo.BlocksWithoutOverlaps'
        blockset_joined = BWO(blockset_joined)
        local Orient = require 'npge.algo.Orient'
        blockset_joined = Orient(blockset_joined)
        assert.equal(blockset_joined,
            model.BlockSet({s1, s2}, {}))
    end)

    it("joins consequent blocks (no self-joinings)",
    function()
        local model = require 'npge.model'
        local s1 = model.Sequence('s1', "ATGC")
        local s2 = model.Sequence('s2', "ATGC")
        local blockset = model.BlockSet({s1, s2}, {
            model.Block({
                model.Fragment(s1, 0, 1, 1),
                model.Fragment(s2, 0, 1, 1),
                model.Fragment(s1, 2, 3, 1),
                model.Fragment(s2, 2, 3, 1),
            }),
        })
        --
        local Join = require 'npge.algo.Join'
        local blockset_joined = Join(blockset)
        local BWO = require 'npge.algo.BlocksWithoutOverlaps'
        blockset_joined = BWO(blockset_joined)
        local Orient = require 'npge.algo.Orient'
        blockset_joined = Orient(blockset_joined)
        assert.equal(blockset_joined,
            model.BlockSet({s1, s2}, {}))
    end)

    it("joins consequent blocks (reversed)",
    function()
        local model = require 'npge.model'
        local s1 = model.Sequence('s1', "ATGC")
        local s2 = model.Sequence('s2', "ATGC")
        local blockset = model.BlockSet({s1, s2}, {
            model.Block({
                model.Fragment(s1, 0, 1, 1),
                model.Fragment(s2, 0, 1, 1),
            }),
            model.Block({
                model.Fragment(s1, 3, 2, -1),
                model.Fragment(s2, 3, 2, -1),
            }),
        })
        --
        local Join = require 'npge.algo.Join'
        local blockset_joined = Join(blockset)
        local BWO = require 'npge.algo.BlocksWithoutOverlaps'
        blockset_joined = BWO(blockset_joined)
        local Orient = require 'npge.algo.Orient'
        blockset_joined = Orient(blockset_joined)
        assert.equal(blockset_joined,
            model.BlockSet({s1, s2}, {
                model.Block({
                    model.Fragment(s1, 0, 3, 1),
                    model.Fragment(s2, 0, 3, 1),
                }),
            }))
    end)

    it("joins consequent blocks (alignment)",
    function()
        local model = require 'npge.model'
        local s1 = model.Sequence('s1', "ATGC")
        local s2 = model.Sequence('s2', "AGC")
        local blockset = model.BlockSet({s1, s2}, {
            model.Block({
                model.Fragment(s1, 0, 0, 1),
                model.Fragment(s2, 0, 0, 1),
            }),
            model.Block({
                model.Fragment(s1, 3, 3, 1),
                model.Fragment(s2, 2, 2, 1),
            }),
        })
        --
        local Join = require 'npge.algo.Join'
        local blockset_joined = Join(blockset)
        local BWO = require 'npge.algo.BlocksWithoutOverlaps'
        blockset_joined = BWO(blockset_joined)
        local Orient = require 'npge.algo.Orient'
        blockset_joined = Orient(blockset_joined)
        assert.equal(blockset_joined,
            model.BlockSet({s1, s2}, {
                model.Block({
                    {model.Fragment(s1, 0, 3, 1), 'ATGC'},
                    {model.Fragment(s2, 0, 2, 1), 'A-GC'},
                }),
            }))
    end)
end)
