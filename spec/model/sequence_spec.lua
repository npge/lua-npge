local Sequence = require 'npge.model.Sequence'

describe("model.sequence", function()
    it("converts to atgcn", function()
        assert.are.equal(Sequence.to_atgcn("a T g"), "ATG")
    end)

    it("calculates complement", function()
        assert.are.equal(Sequence.complement("ATGC"), "GCAT")
    end)

    it("sequence creation", function()
        local s = Sequence("test_name", "ATGC",
            "test description")
        assert.are.equal(s:name(), "test_name")
        assert.are.equal(s:text(), "ATGC")
        assert.are.equal(s:description(), "test description")
    end)

    it("throws on empty sequence", function()
        assert.has_error(function()
            Sequence('name', '')
        end)
    end)

    it("throws on unnamed sequence", function()
        assert.has_error(function()
            Sequence('', 'ATG')
        end)
    end)

    it("sequence creation with no description", function()
        local s = Sequence("test_name", "ATGC")
        assert.are.equal(s:name(), "test_name")
        assert.are.equal(s:text(), "ATGC")
        assert.are.equal(s:description(), '')
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
        assert.is.truthy(s:circular())
    end)

    it("sets genome, chromosome and linear", function()
        local s = Sequence("genome&chromosome&l", "AAA")
        assert.are.equal(s:genome(), "genome")
        assert.are.equal(s:chromosome(), "chromosome")
        assert.is.falsy(s:circular())
    end)

    it("sets bad name", function()
        local s = Sequence("genome&chromosome&l&1", "AAA")
        assert.are.equal(s:genome(), nil)
        assert.are.equal(s:chromosome(), nil)
        assert.is.falsy(s:circular())
    end)

    it("sets bad circularity", function()
        local s = Sequence("genome&chromosome&zzz", "AAA")
        assert.are.equal(s:genome(), "genome")
        assert.are.equal(s:chromosome(), "chromosome")
        assert.is.falsy(s:circular())
    end)

    it("gets letters from sequence's text", function()
        local s = Sequence("test_name", "ATGC")
        assert.are.equal(s:at(0), 'A')
        assert.are.equal(s:at(1), 'T')
        assert.are.equal(s:at(2), 'G')
        assert.are.equal(s:at(3), 'C')
    end)

    it("gets substrings from sequence's text", function()
        local s = Sequence("test_name", "ATGC")
        assert.are.equal(s:sub(0, 1), 'AT')
    end)

    it("gets length of text", function()
        local s = Sequence("test_name", "ATGC")
        assert.are.equal(s:length(), 4)
    end)

    it("has type Sequence", function()
        local s = Sequence("test_name", "ATGC")
        assert.are.equal(s:type(), "Sequence")
    end)

    it("serializes to Lua", function()
        local s1 = Sequence("test_name", "ATGC")
        local lua = s1:tolua()
        local s2 = loadstring(lua)()
        assert.equal(s1:name(), s2:name())
        assert.equal(s1:text(), s2:text())
        assert.equal(s1:description(), s2:description())
    end)

    it("serializes to Lua (description)", function()
        local s1 = Sequence("test_name", "ATGC", "ddd ddd")
        local lua = s1:tolua()
        local s2 = loadstring(lua)()
        assert.equal(s1:name(), s2:name())
        assert.equal(s1:text(), s2:text())
        assert.equal(s1:description(), s2:description())
    end)

    it("serializes to Lua (long sequence)", function()
        local text = string.rep("ATGGG", 100)
        local s1 = Sequence("test_name", text)
        local lua = s1:tolua()
        local s2 = loadstring(lua)()
        assert.equal(s1:name(), s2:name())
        assert.equal(s1:text(), s2:text())
        assert.equal(s1:description(), s2:description())
    end)

    it("compares sequences", function()
        local s1 = Sequence("test_name", 'ATGC')
        local s2 = Sequence("test_name", 'ATGC')
        assert.equal(s1, s1)
        assert.equal(s1, s2)
    end)

end)
