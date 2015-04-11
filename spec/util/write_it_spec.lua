-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

describe("npge.util.writeIt", function()
    it("writes output of iterator to file", function()
        local writeIt = require 'npge.util.writeIt'
        local itFromArray = require 'npge.util.itFromArray'
        local array = {"123\n", "456\n"}
        local tmp_fname = os.tmpname()
        writeIt(tmp_fname, itFromArray(array))
        local tmp_f = io.open(tmp_fname, 'rb')
        local text = tmp_f:read('*a')
        tmp_f:close()
        os.remove(tmp_fname)
        assert.equal(text, '123\n456\n')
    end)
end)
