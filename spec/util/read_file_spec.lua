-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

describe("npge.util.read_file", function()
    it("reads whole file", function()
        local fname = os.tmpname()
        local f = io.open(fname, 'w')
        f:write('test')
        f:close()
        local read_file = require 'npge.util.read_file'
        assert.equal(read_file(fname), 'test')
        os.remove(fname)
    end)
end)
