
local Fragment = {}
local Fragment_mt = {}
local f_mt = {}

Fragment_mt.__index = Fragment_mt
f_mt.__index = f_mt

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
    return setmetatable(f, f_mt)
end

f_mt.seq = function(self)
    return self._seq
end

f_mt.start = function(self)
    return self._start
end

f_mt.stop = function(self)
    return self._stop
end

f_mt.ori = function(self)
    return self._ori
end

f_mt.__eq = function(self, other)
    return self:seq() == other:seq() and
        self:start() == other:start() and
        self:stop() == other:stop() and
        self:ori() == other:ori()
end

f_mt.parted = function(self)
    local diff = self:stop() - self:start()
    -- (diff < 0 and self:ori() == 1) or ...
    return diff * self:ori() < 0
end

f_mt.parts = function(self)
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

f_mt.size = function(self)
    local math = require('math')
    local absdiff = math.abs(self:stop() - self:start())
    if not self:parted() then
        return absdiff + 1
    else
        return self:seq():size() - absdiff + 1
    end
end

f_mt.text = function(self)
    if not self:parted() then
        local math = require('math')
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

f_mt.has = function(self, index)
    if not self:parted() then
        if self:ori() == 1 then
            return index >= self:start() and
                index <= self:stop()
        else
            return index <= self:start() and
                index >= self:stop()
        end
    else
        local a, b = self:parts()
        return a:has(index) or b:has(index)
    end
end

local fix_coord = function(seq, x)
    if x < 0 then
        return x + seq:size()
    elseif x >= seq:size() then
        return x - seq:size()
    else
        return x
    end
end

f_mt.is_subfragment_of = function(self, source)
    assert(self:seq() == source:seq())
    if not source:has(self:start())
            or not source:has(self:stop()) then
        return false
    end
    if not source:parted() and not self:parted() then
        return true
    elseif source:size() == source:seq():size() then
        -- source covers whole sequence
        return true
    else
        -- check all boundaries of source
        local points = {source:start(), source:stop()}
        local points1 = {}
        for _, point in ipairs(points) do
            table.insert(points1, point - 1)
            table.insert(points1, point)
            table.insert(points1, point + 1)
        end
        for _, point in ipairs(points1) do
            point = fix_coord(self:seq(), point)
            if self:has(point) and not source:has(point) then
                return false
            end
        end
        return true
    end
end

f_mt.subfragment = function(self, start, stop, ori)
    -- ori is related to source fragment
    local start2 = self:start() + self:ori() * start
    local stop2 = self:start() + self:ori() * stop
    local ori2 = self:ori() * ori
    start2 = fix_coord(self:seq(), start2)
    stop2 = fix_coord(self:seq(), stop2)
    local f = Fragment(self:seq(), start2, stop2, ori2)
    assert(f:is_subfragment_of(self))
    return f
end

f_mt.sub = function(self, start, stop, ori)
    return self:subfragment(start, stop, ori):text()
end

f_mt.at = function(self, index)
    local seq_index = self:start() + index * self:ori()
    seq_index = fix_coord(self:seq(), seq_index)
    local letter = self:seq():at(seq_index)
    if self:ori() == 1 then
        return letter
    else
        local Sequence = require 'npge.model.Sequence'
        return Sequence.complement(letter)
    end
end

return setmetatable(Fragment, Fragment_mt)

