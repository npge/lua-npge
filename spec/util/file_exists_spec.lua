-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

describe("npge.util.fileExists", function()
    it("checks if file exists", function()
        local fileExists = require 'npge.util.fileExists'
        local tmp_fname = os.tmpname()
        local tmp_f = io.open(tmp_fname, 'w')
        tmp_f:write('test')
        tmp_f:close()
        assert.truthy(fileExists(tmp_fname))
        os.remove(tmp_fname)
        assert.truthy(not fileExists(tmp_fname))
    end)
end)
