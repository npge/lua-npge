-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2016 Boris Nagaev
-- See the LICENSE file for terms of use.

describe("npge.util.writeFile", function()
    it("writes string to file", function()
        local writeFile = require 'npge.util.writeFile'
        local tmpName = require 'npge.util.tmpName'
        local tmp_fname = tmpName()
        writeFile(tmp_fname, "42")
        local readFile = require 'npge.util.readFile'
        assert.equal(readFile(tmp_fname), "42")
        os.remove(tmp_fname)
    end)
end)
