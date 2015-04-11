-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

describe("npge.alignment.unwindRow", function()
    it("unwinds row on consensus using a row on original",
    function()
        local unwindRow = require 'npge.alignment.unwindRow'
        assert.equal(unwindRow('AAA', 'AAA'), 'AAA')
        assert.equal(unwindRow('ATA', 'AAA'), 'AAA')
        assert.equal(unwindRow('A-AA', 'AAA'), 'A-AA')
        assert.equal(unwindRow('ATGC', 'ATGC'), 'ATGC')
        assert.equal(unwindRow('ATGC', 'AT-C'), 'AT-C')
        assert.equal(unwindRow('A-TGC', 'AT-C'), 'A-T-C')
    end)

    it("throws if consensus row does not match original row",
    function()
        local unwindRow = require 'npge.alignment.unwindRow'
        assert.has_error(function()
            unwindRow('ATGC', 'ATG')
        end)
        assert.has_error(function()
            unwindRow('ATG', 'ATGC')
        end)
        assert.has_error(function()
            unwindRow('A--C', 'ATG')
        end)
    end)
end)
