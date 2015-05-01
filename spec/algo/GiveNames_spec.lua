-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

describe("npge.algo.GiveNames", function()
    it("generates names for blocks from blockset", function()
        local config = require 'npge.config'
        local revert = config:updateKeys({
            general = {
                MIN_LENGTH = 100,
                MIN_IDENTITY = 0.9,
                MIN_END = 3,
            },
        })
        --
        local model = require 'npge.model'
        local text = ("A"):rep(1000)
        local g1c1 = model.Sequence("g1&c1&c", text)
        local g2c1 = model.Sequence("g2&c1&c", text)
        local g3c1 = model.Sequence("g3&c1&c", text)
        local F = model.Fragment
        local B = model.Block
        local BS = model.BlockSet
        local GiveNames = require 'npge.algo.GiveNames'
        local bs = GiveNames(BS({g1c1, g2c1, g3c1}, {
            B({
                F(g1c1, 1, 1, 1),
            }),
            B({
                F(g1c1, 1, 1, 1),
                F(g1c1, 2, 2, 1),
            }),
            B({
                F(g1c1, 0, 400, 1),
            }),
            B({
                F(g1c1, 1, 100, 1),
            }),
            B({
                F(g1c1, 1, 99, 1),
            }),
            B({
                F(g1c1, 1, 99, 1),
                F(g2c1, 1, 99, 1),
            }),
            B({
                F(g1c1, 1, 200, 1),
                F(g1c1, 51, 250, 1),
            }),
            B({
                F(g1c1, 11, 210, 1),
                F(g1c1, 51, 250, 1),
            }),
            B({
                F(g1c1, 1, 200, 1),
                F(g2c1, 51, 250, 1),
            }),
            B({
                F(g1c1, 1, 200, 1),
                F(g1c1, 51, 250, 1),
                F(g2c1, 51, 250, 1),
            }),
            B({
                F(g1c1, 1, 200, 1),
                F(g2c1, 51, 250, 1),
                F(g3c1, 51, 250, 1),
            }),
            B({
                F(g1c1, 1, 200, 1),
                F(g1c1, 51, 250, 1),
                F(g2c1, 1, 200, 1),
                F(g2c1, 51, 250, 1),
                F(g3c1, 1, 200, 1),
                F(g3c1, 51, 250, 1),
            }),
        }))
        -- check names
        assert.equal(bs:nameByBlock(B({
            F(g1c1, 1, 1, 1),
        })), "m1x1")
        assert.equal(bs:nameByBlock(B({
            F(g1c1, 1, 1, 1),
            F(g1c1, 2, 2, 1),
        })), "m2x1")
        assert.equal(bs:nameByBlock(B({
            F(g1c1, 0, 400, 1),
        })), "u1x401")
        assert.equal(bs:nameByBlock(B({
            F(g1c1, 1, 100, 1),
        })), "u1x100")
        assert.equal(bs:nameByBlock(B({
            F(g1c1, 1, 99, 1),
        })), "m1x99")
        assert.equal(bs:nameByBlock(B({
            F(g1c1, 1, 99, 1),
            F(g2c1, 1, 99, 1),
        })), "m2x99")
        assert.truthy(
            bs:nameByBlock(B({
                F(g1c1, 1, 200, 1),
                F(g1c1, 51, 250, 1),
            })) == "r2x200"
        or
            bs:nameByBlock(B({
                F(g1c1, 1, 200, 1),
                F(g1c1, 51, 250, 1),
            })) == "r2x200n1"
        )
        assert.truthy(
            bs:nameByBlock(B({
                F(g1c1, 11, 210, 1),
                F(g1c1, 51, 250, 1),
            })) == "r2x200"
        or
            bs:nameByBlock(B({
                F(g1c1, 11, 210, 1),
                F(g1c1, 51, 250, 1),
            })) == "r2x200n1"
        )
        assert.equal(bs:nameByBlock(B({
            F(g1c1, 1, 200, 1),
            F(g2c1, 51, 250, 1),
        })), "h2x200")
        assert.equal(bs:nameByBlock(B({
            F(g1c1, 1, 200, 1),
            F(g1c1, 51, 250, 1),
            F(g2c1, 51, 250, 1),
        })), "r3x200")
        assert.equal(bs:nameByBlock(B({
            F(g1c1, 1, 200, 1),
            F(g2c1, 51, 250, 1),
            F(g3c1, 51, 250, 1),
        })), "s3x200")
        assert.equal(bs:nameByBlock(B({
            F(g1c1, 1, 200, 1),
            F(g1c1, 51, 250, 1),
            F(g2c1, 1, 200, 1),
            F(g2c1, 51, 250, 1),
            F(g3c1, 1, 200, 1),
            F(g3c1, 51, 250, 1),
        })), "r6x200")
        --
        revert()
    end)
end)
