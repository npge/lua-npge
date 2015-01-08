describe("fragment.at", function()
    it("gets char by index (positive)", function()
        local model = require 'npge.model'
        local s = model.Sequence("genome&chromosome&c", "ATGC")
        local f = model.Fragment(s, 1, 2, 1)
        local at = require 'npge.fragment.at'
        assert.are.equal(at(f, 0), "T")
        assert.are.equal(at(f, 1), "G")
    end)

    it("gets char by index (negative)", function()
        local model = require 'npge.model'
        local s = model.Sequence("genome&chromosome&c", "ATGC")
        local f = model.Fragment(s, 1, 2, -1)
        local at = require 'npge.fragment.at'
        assert.are.equal(at(f, 0), "A")
        assert.are.equal(at(f, 1), "T")
        assert.are.equal(at(f, 2), "G")
        assert.are.equal(at(f, 3), "C")
    end)
end)
