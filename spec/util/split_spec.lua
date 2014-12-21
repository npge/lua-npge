local split = require 'npge.util.split'

describe("util.split", function()
    it("split by space", function()
        assert.are.same(split("a b c"), {"a", "b", "c"})
    end)

    it("split by comma", function()
        assert.are.same(split("a,b,c", ','), {"a", "b", "c"})
    end)

    it("split by spaces", function()
        assert.are.same(split("a b  c"), {"a", "b", "c"})
    end)

    it("split by spaces (not stripped)", function()
        assert.are.same(split(" a b "), {"", "a", "b", ""})
    end)

    it("max splits", function()
        assert.are.same(split("a b c", nil, 1), {"a", "b c"})
    end)

    it("respects patterns", function()
        assert.are.same(split("a1b", '%d'), {"a", "b"})
    end)

    it("respects plain", function()
        assert.are.same(split("a1b", '%d', nil, true), {"a1b"})
    end)
end)
