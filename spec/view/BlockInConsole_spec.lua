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
    local tmpName = require 'npge.util.tmpName'
    local fname = tmpName()
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
        local has_rote, rote = pcall(require, 'rote')
        local has_alnbox, alnbox = pcall(require, 'alnbox')
        if not has_rote or not has_alnbox then
            -- Dependencies are not installed
            if not has_alnbox then
                assert.has_error(function()
                    local npge = require 'npge'
                    local model = npge.model
                    local s = model.Sequence("ttt", "AATAT")
                    local f1 = model.Fragment(s, 0, 2, 1)
                    local f2 = model.Fragment(s, 4, 3, -1)
                    local block = model.Block({
                        {f1, "AAT"},
                        {f2, "-AT"}
                    })
                    npge.view.BlockInConsole(block)
                end)
            end
            return
        end
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
