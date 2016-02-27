-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2016 Boris Nagaev
-- See the LICENSE file for terms of use.

describe("npge.util.execute", function()
    it("executes a program", function()
        local tmpName = require 'npge.util.tmpName'
        local tmp_fname = tmpName()
        os.remove(tmp_fname)
        local nullName = require 'npge.util.nullName'
        local cmd = ('mkdir %s 2> %s'):format(tmp_fname, nullName())
        local execute = require 'npge.util.execute'
        assert.truthy(execute(cmd))
        assert.falsy(execute(cmd))
        os.remove(tmp_fname)
    end)
end)
