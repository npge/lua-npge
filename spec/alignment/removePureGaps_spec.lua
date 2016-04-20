-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2016 Boris Nagaev
-- See the LICENSE file for terms of use.

describe("npge.alignment.removePureGaps", function()
    it("remove pure gap columns", function()
        local removePureGaps = require 'npge.alignment.removePureGaps'
        assert.same(removePureGaps({}), {})
        assert.same(removePureGaps({""}), {""})
        assert.same(removePureGaps({"-"}), {""})
        assert.same(removePureGaps({"-", "-"}), {"", ""})
        assert.same(removePureGaps({
            "AATTCAGGA-TCAAAAAT",
            "AATTCAGGA-TCAAAAAT",
            "AATTCACGA-TCGAAAAT",
        }), {
            "AATTCAGGATCAAAAAT",
            "AATTCAGGATCAAAAAT",
            "AATTCACGATCGAAAAT",
        })
    end)

    it("throws if the argument is nil", function()
        local removePureGaps = require 'npge.alignment.removePureGaps'
        assert.has_error(function()
            removePureGaps()
        end)
    end)

    it("throws if lengths of rows differ", function()
        local removePureGaps = require 'npge.alignment.removePureGaps'
        assert.has_error(function()
            removePureGaps({"A", "A-"})
        end)
    end)
end)
