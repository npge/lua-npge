local model = require 'npge.model'

describe("model.fragment", function()
    it("creates fragment", function()
        local s = model.Sequence("test_name", "ATGC")
        local f = model.Fragment(s, 0, 3, 1)
        assert.are.equal(f:seq(), s)
        assert.are.equal(f:start(), 0)
        assert.are.equal(f:stop(), 3)
        assert.are.equal(f:ori(), 1)
    end)

    local Fragment = require 'npge.model.Fragment'
    local fragment_gen = function(seq, start, stop, ori)
        return function()
            return Fragment(seq, start, stop, ori)
        end
    end

    it("throws on bad fragment", function()
        -- linear
        local s = model.Sequence("genome&chromosome&l", "ATGC")
        assert.has.errors(fragment_gen(nil, 1, 2, 1))
        assert.has.errors(fragment_gen(s, 100, 110, 1))
        assert.has.errors(fragment_gen(s, 1, 2, 10))
        assert.has.errors(fragment_gen(s, 0, 4, 1))
        assert.has.errors(fragment_gen(s, 2, 1, 1))
        assert.has.errors(fragment_gen(s, 1, 2, -1))
    end)

    it("no throw on parted fragments on circular", function()
        -- circular
        local s = model.Sequence("genome&chromosome&c", "ATGC")
        assert.has_no.errors(fragment_gen(s, 2, 1, 1))
        assert.has_no.errors(fragment_gen(s, 1, 2, -1))
    end)
end)

