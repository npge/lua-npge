
local Fragment = {}

local Fragment_mt = {}
Fragment_mt.__index = Fragment_mt

Fragment_mt.__call = function(self, seq, start, stop, ori)
    assert(seq:type() == 'Sequence')
    assert(type(start) == 'number')
    assert(type(stop) == 'number')
    assert(type(ori) == 'number')
    assert(start >= 0)
    assert(start < seq:size())
    assert(stop >= 0)
    assert(stop < seq:size())
    assert(ori == 1 or ori == -1)
    if seq:circularity() ~= 'c' then
        -- forbid parted fragments on linear sequences
        if ori == 1 then
            assert(start <= stop)
        else
            assert(start >= stop)
        end
    end
    local f = {_seq=seq, _start=start, _stop=stop, _ori=ori}
    return setmetatable(f, Fragment_mt)
end

Fragment_mt.seq = function(self)
    return self._seq
end

Fragment_mt.start = function(self)
    return self._start
end

Fragment_mt.stop = function(self)
    return self._stop
end

Fragment_mt.ori = function(self)
    return self._ori
end

Fragment_mt.parted = function(self)
    local diff = self:stop() - self:start()
    -- (diff < 0 and self:ori() == 1) or ...
    return diff * self:ori() < 0
end

Fragment_mt.parts = function(self)
    assert(self:parted())
    local last = self:seq():size() - 1
    if self:ori() == 1 then
        return Fragment(self:seq(), self:start(), last, 1),
               Fragment(self:seq(), 0, self:stop(), 1)
    else
        return Fragment(self:seq(), self:start(), 0, -1),
               Fragment(self:seq(), last, self:stop(), -1)
    end
end

Fragment_mt.size = function(self)
    local math = require('math')
    local absdiff = math.abs(self:stop() - self:start())
    if not self:parted() then
        return absdiff + 1
    else
        return self:seq():size() - absdiff + 1
    end
end

Fragment_mt.text = function(self)
    local math = require('math')
    if not self:parted() then
        local min = math.min(self:start(), self:stop())
        local max = math.max(self:start(), self:stop())
        local text = self:seq():sub(min, max)
        if self:ori() == 1 then
            return text
        else
            local Sequence = require 'npge.model.Sequence'
            return Sequence.complement(text)
        end
    else
        local a, b = self:parts()
        return a:text() .. b:text()
    end
end

return setmetatable(Fragment, Fragment_mt)

