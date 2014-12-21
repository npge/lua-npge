local Sequence = require 'npge.model.Sequence'

describe("model.sequence", function()
    it("sequence creation", function()
        local s = Sequence("test_name", "ATGC",
            "test description")
        assert.are.equal(s:name(), "test_name")
        assert.are.equal(s:text(), "ATGC")
        assert.are.equal(s:description(), "test description")
    end)

    it("sequence creation with no description", function()
        local s = Sequence("test_name", "ATGC")
        assert.are.equal(s:name(), "test_name")
        assert.are.equal(s:text(), "ATGC")
        assert.are.equal(s:description(), nil)
    end)

    it("sequence with lower text", function()
        local s = Sequence("test_name", "atgc")
        assert.are.equal(s:text(), "ATGC")
    end)

    it("sequence with gaps", function()
        local s = Sequence("test_name", "AT-GC")
        assert.are.equal(s:text(), "ATGC")
    end)

    it("sequence with new lines", function()
        local s = Sequence("test_name", "AT\nGC")
        assert.are.equal(s:text(), "ATGC")
    end)

    it("sequence with N", function()
        local s = Sequence("test_name", "ATNGC")
        assert.are.equal(s:text(), "ATNGC")
    end)

    it("sequence with Cornish-Bowden notation", function()
        local s = Sequence("test_name", "ATYGC")
        assert.are.equal(s:text(), "ATNGC")
    end)

    it("sets genome, chromosome and circular", function()
        local s = Sequence("genome&chromosome&c", "AAA")
        assert.are.equal(s:genome(), "genome")
        assert.are.equal(s:chromosome(), "chromosome")
        assert.are.equal(s:circularity(), "c")
    end)

    it("sets genome, chromosome and linear", function()
        local s = Sequence("genome&chromosome&l", "AAA")
        assert.are.equal(s:genome(), "genome")
        assert.are.equal(s:chromosome(), "chromosome")
        assert.are.equal(s:circularity(), "l")
    end)

    it("sets bad name", function()
        local s = Sequence("genome&chromosome&l&1", "AAA")
        assert.are.equal(s:genome(), nil)
        assert.are.equal(s:chromosome(), nil)
        assert.are.equal(s:circularity(), nil)
    end)

    it("sets bad circularity", function()
        local s = Sequence("genome&chromosome&zzz", "AAA")
        assert.are.equal(s:genome(), "genome")
        assert.are.equal(s:chromosome(), "chromosome")
        assert.are.equal(s:circularity(), nil)
    end)
end)
