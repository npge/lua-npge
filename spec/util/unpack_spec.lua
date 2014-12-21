local unpack = require 'npge.util.unpack'

describe("util.unpack", function()
    it("unpack works", function()
        local a, b = unpack({1, 2})
        assert.are.same({a, b}, {1, 2})
    end)
end)

