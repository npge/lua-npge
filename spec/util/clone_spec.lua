local clone = require 'npge.util.clone'

describe("util.clone", function()
    it("makes a copy of an array", function()
        local x = {1, 2}
        assert.same(clone.array(x), x)
        assert.not_equal(clone.array(x), x)
    end)

    it("makes an array from an iterator", function()
        local i = 0
        local it = function()
            i = i + 1
            if i < 5 then
                return i
            end
        end
        assert.same(clone.array_from_it(it), {1, 2, 3, 4})
    end)

    it("makes a copy of a dict", function()
        local x = {a = 1, b = 'c', [1] = 0}
        assert.same(clone.dict(x), x)
        assert.not_equal(clone.dict(x), x)
    end)

    it("makes a dict from an iterator", function()
        local i = 0
        local it = function()
            i = i + 1
            if i < 3 then
                return 'k' .. i, i
            end
        end
        assert.same(clone.dict_from_it(it), {k1 = 1, k2 = 2})
    end)
end)

