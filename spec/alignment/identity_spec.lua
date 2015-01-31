describe("alignment.identity", function()
    it("finds identity of rows (50%)", function()
        local identity = require 'npge.alignment.identity'
        local eq = require 'npge.block.identity'.eq
        assert.truthy(eq(identity({'AT', 'TT'}), 0.5))
    end)

    it("finds identity of rows (slice)", function()
        local identity = require 'npge.alignment.identity'
        local eq = require 'npge.block.identity'.eq
        assert.truthy(eq(identity({'AT', 'TT'}, 0, 0), 0))
        assert.truthy(eq(identity({'AT', 'TT'}, 0, 1), 0.5))
        assert.truthy(eq(identity({'AT', 'TT'}, 1, 1), 1))
    end)

    it("finds identity of rows (throws if bad slice)",
    function()
        local identity = require 'npge.alignment.identity'
        assert.has_error(function()
            identity({'AT', 'TT'}, -1, 0)
        end)
        assert.has_error(function()
            identity({'AT', 'TT'}, 1, 0)
        end)
        assert.has_error(function()
            identity({'AT', 'TT'}, 1, 2)
        end)
    end)

    it("returns number of ident columns and total length",
    function()
        local identity = require 'npge.alignment.identity'
        local eq = require 'npge.block.identity'.eq
        local _, nident, ncols = identity({'A-T', 'TTT'})
        assert.truthy(eq(nident, 1.5))
        assert.truthy(eq(ncols, 3))
    end)
end)
