return function(code, enable_fromRef)
    local UnsafeSequence = require 'npge.model.Sequence'
    local Sequence = function(...)
        -- Sequence.fromRef is disabled
        return UnsafeSequence(...)
    end
    if enable_fromRef then
        Sequence = UnsafeSequence
    end
    local sandboxed = {
        model = {
            Sequence = Sequence,
            Fragment = require 'npge.model.Fragment',
            Block = require 'npge.model.Block',
            BlockSet = require 'npge.model.BlockSet',
        }
    }
    local modules = {
        ['npge'] = sandboxed,
        ['npge.model'] = sandboxed.model,
        ['npge.model.Sequence'] = sandboxed.model.Sequence,
        ['npge.model.Fragment'] = sandboxed.model.Fragment,
        ['npge.model.Block'] = sandboxed.model.Block,
        ['npge.model.BlockSet'] = sandboxed.model.BlockSet,
    }
    local env = {
        require = function(name)
            return modules[name]
        end,
        _VERSION=_VERSION, select=select, ipairs=ipairs,
        next=next, pairs=pairs, pcall=pcall,
        tonumber=tonumber, tostring=tostring,
        type=type,
        unpack = unpack or table.unpack,
        string = {
            byte=string.byte, char=string.char,
            format=string.format, len=string.len,
            lower=string.lower, reverse=string.reverse,
            sub=string.sub, upper=string.upper,
        },
        table = {
            insert=table.insert, maxn=table.maxn,
            remove=table.remove, sort=table.sort,
            unpack=table.unpack,
        },
        math = {
            abs=math.abs, acos=math.acos, asin=math.asin,
            atan=math.atan, atan2=math.atan2, ceil=math.ceil,
            cos=math.cos, cosh=math.cosh, deg=math.deg,
            exp=math.exp, floor=math.floor,
            fmod=math.fmod, frexp=math.frexp, huge=math.huge,
            ldexp=math.ldexp, log=math.log, log10=math.log10,
            max=math.max, min=math.min, modf=math.modf,
            pi=math.pi, pow=math.pow, rad=math.rad,
            random=math.random, sin=math.sin, sinh=math.sinh,
            sqrt=math.sqrt, tan=math.tan, tanh=math.tanh,
        },
        os = {
            clock=os.clock, time=os.time,
            difftime=os.difftime,
        },
    }
    local sandbox = require 'npge.util.sandbox'
    local f, message = sandbox(env, code)
    assert(f, message)
    return f()
end
