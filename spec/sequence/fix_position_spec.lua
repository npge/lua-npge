-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2016 Boris Nagaev
-- See the LICENSE file for terms of use.

describe("npge.sequence.fixPosition", function()
    it("translates out-of-sequence positions", function()
        local model = require 'npge.model'
        local s = model.Sequence("g&c&c", "ATAT")
        local fixPosition =
            require 'npge.sequence.fixPosition'
        assert.equal(fixPosition(s, 0), 0)
        assert.equal(fixPosition(s, 1), 1)
        assert.equal(fixPosition(s, 2), 2)
        assert.equal(fixPosition(s, 3), 3)
        assert.equal(fixPosition(s, -1), 3)
        assert.equal(fixPosition(s, 4), 0)
    end)

    it("throws if out-of-sequence on linear sequence",
    function()
        local model = require 'npge.model'
        local s = model.Sequence("g&c&l", "ATAT")
        local fixPosition =
            require 'npge.sequence.fixPosition'
        assert.has_error(function()
            fixPosition(s, -1)
        end)
    end)
end)
