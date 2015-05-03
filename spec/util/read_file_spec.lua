-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

describe("npge.util.readFile", function()
    it("reads whole file", function()
        local tmpName = require 'npge.util.tmpName'
        local fname = tmpName()
        local f = io.open(fname, 'w')
        f:write('test')
        f:close()
        local readFile = require 'npge.util.readFile'
        assert.equal(readFile(fname), 'test')
        os.remove(fname)
    end)
end)
