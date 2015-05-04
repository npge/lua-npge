-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

describe("npge.alignment.identity", function()
    it("finds identity of rows (50%)", function()
        local identity = require 'npge.alignment.identity'
        assert.equal(identity({'AT', 'TT'}), 0.5)
    end)

    it("finds identity of rows (slice)", function()
        local identity = require 'npge.alignment.identity'
        assert.equal(identity({'AT', 'TT'}, 0, 0), 0)
        assert.equal(identity({'AT', 'TT'}, 0, 1), 0.5)
        assert.equal(identity({'AT', 'TT'}, 1, 1), 1)
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
        local _, nident, ncols = identity({'A-T', 'TTT'})
        assert.equal(nident, 1)
        assert.equal(ncols, 3)
    end)

    it("returns 0,0,0 if list of rows is empty", function()
        local identity = require 'npge.alignment.identity'
        local identity, nident, ncols = identity({})
        assert.equal(identity, 0)
        assert.equal(nident, 0)
        assert.equal(ncols, 0)
    end)

    it("returns 0,0,0 if length is 0", function()
        local identity = require 'npge.alignment.identity'
        local identity, nident, ncols = identity({'', ''})
        assert.equal(identity, 0)
        assert.equal(nident, 0)
        assert.equal(ncols, 0)
    end)
end)
