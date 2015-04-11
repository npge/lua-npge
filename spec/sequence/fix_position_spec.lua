-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

describe("npge.sequence.fix_position", function()
    it("translates out-of-sequence positions", function()
        local model = require 'npge.model'
        local s = model.Sequence("g&c&c", "ATAT")
        local fix_position =
            require 'npge.sequence.fix_position'
        assert.equal(fix_position(s, 0), 0)
        assert.equal(fix_position(s, 1), 1)
        assert.equal(fix_position(s, 2), 2)
        assert.equal(fix_position(s, 3), 3)
        assert.equal(fix_position(s, -1), 3)
        assert.equal(fix_position(s, 4), 0)
    end)

    it("throws if out-of-sequence on linear sequence",
    function()
        local model = require 'npge.model'
        local s = model.Sequence("g&c&l", "ATAT")
        local fix_position =
            require 'npge.sequence.fix_position'
        assert.has_error(function()
            fix_position(s, -1)
        end)
    end)
end)
