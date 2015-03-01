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

    it("throws if length of rows is not constant",
    function()
        local identity = require 'npge.alignment.identity'
        assert.has_error(function()
            identity({'AT', 'TTA'})
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

    it("returns 0,0,0 if list of rows is empty", function()
        local identity = require 'npge.alignment.identity'
        local eq = require 'npge.block.identity'.eq
        local identity, nident, ncols = identity({})
        assert.truthy(eq(identity, 0))
        assert.truthy(eq(nident, 0))
        assert.truthy(eq(ncols, 0))
    end)

    it("returns 0,0,0 if length is 0", function()
        local identity = require 'npge.alignment.identity'
        local eq = require 'npge.block.identity'.eq
        local identity, nident, ncols = identity({'', ''})
        assert.truthy(eq(identity, 0))
        assert.truthy(eq(nident, 0))
        assert.truthy(eq(ncols, 0))
    end)
end)
