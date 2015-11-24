-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

describe("npge.util.stats", function()
    it("calculates min, max, med, avg, sum", function()
        local stats = require 'npge.util.stats'
        local min, max, med, avg, sum = stats({4, 1, 2, 2})
        assert.equal(min, 1)
        assert.equal(med, 2)
        assert.equal(avg, 2.25)
        assert.equal(max, 4)
        assert.equal(sum, 9)
    end)

    it("calculates median (odd)", function()
        local stats = require 'npge.util.stats'
        local min, max, med, avg = stats({1, 5, 100})
        assert.equal(med, 5)
    end)

    it("calculates median (even)", function()
        local stats = require 'npge.util.stats'
        local min, max, med, avg = stats({1, 5, 7, 100})
        assert.equal(med, 6)
    end)
end)

