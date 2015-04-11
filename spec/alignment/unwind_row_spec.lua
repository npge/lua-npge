-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

describe("npge.alignment.unwind_row", function()
    it("unwinds row on consensus using a row on original",
    function()
        local unwind_row = require 'npge.alignment.unwind_row'
        assert.equal(unwind_row('AAA', 'AAA'), 'AAA')
        assert.equal(unwind_row('ATA', 'AAA'), 'AAA')
        assert.equal(unwind_row('A-AA', 'AAA'), 'A-AA')
        assert.equal(unwind_row('ATGC', 'ATGC'), 'ATGC')
        assert.equal(unwind_row('ATGC', 'AT-C'), 'AT-C')
        assert.equal(unwind_row('A-TGC', 'AT-C'), 'A-T-C')
    end)

    it("throws if consensus row does not match original row",
    function()
        local unwind_row = require 'npge.alignment.unwind_row'
        assert.has_error(function()
            unwind_row('ATGC', 'ATG')
        end)
        assert.has_error(function()
            unwind_row('ATG', 'ATGC')
        end)
        assert.has_error(function()
            unwind_row('A--C', 'ATG')
        end)
    end)
end)
