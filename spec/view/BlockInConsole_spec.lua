-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use

local function sleep()
    local duration = os.getenv('TEST_SLEEP') or 5
    os.execute('sleep ' .. duration)
end

local function startCode(rt, code)
    if type(code) == 'function' then
        code = string.dump(code)
    end
    local fname = os.tmpname()
    local f = io.open(fname, 'w')
    f:write(code)
    f:close()
    local lluacov = os.getenv('LOAD_LUACOV') or ''
    local cmd = 'lua %s %s; rm %s'
    cmd = cmd:format(lluacov, fname, fname)
    rt:forkPty(cmd)
end

describe("npge.view.BlockInConsole", function()
    it("draws simple alignment", function()
        local rote = require 'rote'
        local rt = rote.RoteTerm(24, 80)
        startCode(rt, function()
            local npge = require 'npge'
            local model = npge.model
            local s = model.Sequence("test_name", "AATAT")
            local f1 = model.Fragment(s, 0, 2, 1)
            local f2 = model.Fragment(s, 4, 3, -1)
            local block = model.Block({
                {f1, "AAT"},
                {f2, "-AT"}
            })
            npge.view.BlockInConsole(block)
        end)
        sleep()
        rt:update()
        assert.truthy(rt:termText():match('test_name'))
        assert.truthy(rt:termText():match('AAT'))
        assert.truthy(rt:termText():match('-AT'))
        rt:write('q')
    end)
end)
