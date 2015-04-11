-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

describe("npge.util.file_exists", function()
    it("checks if file exists", function()
        local file_exists = require 'npge.util.file_exists'
        local tmp_fname = os.tmpname()
        local tmp_f = io.open(tmp_fname, 'w')
        tmp_f:write('test')
        tmp_f:close()
        assert.truthy(file_exists(tmp_fname))
        os.remove(tmp_fname)
        assert.truthy(not file_exists(tmp_fname))
    end)
end)
