local Sequence = require 'npge.model.Sequence'

describe("sequence", function()
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
end)
