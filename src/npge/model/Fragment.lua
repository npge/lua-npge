
local Fragment = {}
local Fragment_mt = {}
local f_mt = {}

Fragment_mt.__index = Fragment_mt
f_mt.__index = f_mt

Fragment_mt.__call = function(self, seq, start, stop, ori)
    assert(seq)
    assert(seq:type() == 'Sequence')
    assert(type(start) == 'number')
    assert(type(stop) == 'number')
    assert(type(ori) == 'number')
    assert(start >= 0)
    assert(start < seq:length())
    assert(stop >= 0)
    assert(stop < seq:length())
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

f_mt.type = function(self)
    return 'Fragment'
end

f_mt.sequence = function(self)
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

f_mt.id = function(self)
    return ("%s_%s_%s_%s"):format(
        self:sequence():name(),
        self:start(),
        self:stop(),
        self:ori())
end

local function f_as_arr(self)
    return {self:sequence():name(), self:start(),
        self:stop(), self:ori()}
end

f_mt.__eq = function(self, other)
    assert(other and other:type() == 'Fragment')
    local arrays_equal = require 'npge.util.arrays_equal'
    return arrays_equal(f_as_arr(self), f_as_arr(other))
end

local function f_as_arr2(self)
    assert(not self:parted())
    local math = require('math')
    local min = math.min(self:start(), self:stop())
    local max = math.max(self:start(), self:stop())
    return {self:sequence():name(), min, max, self:ori()}
end

f_mt.__lt = function(self, other)
    assert(other and other:type() == 'Fragment')
    local arrays_less = require 'npge.util.arrays_less'
    return arrays_less(f_as_arr2(self), f_as_arr2(other))
end

f_mt.parted = function(self)
    local diff = self:stop() - self:start()
    -- (diff < 0 and self:ori() == 1) or ...
    return diff * self:ori() < 0
end

f_mt.parts = function(self)
    assert(self:parted())
    local last = self:sequence():length() - 1
    local seq = self:sequence()
    if self:ori() == 1 then
        return Fragment(seq, self:start(), last, 1),
               Fragment(seq, 0, self:stop(), 1)
    else
        return Fragment(seq, self:start(), 0, -1),
               Fragment(seq, last, self:stop(), -1)
    end
end

f_mt.length = function(self)
    local math = require('math')
    local absdiff = math.abs(self:stop() - self:start())
    if not self:parted() then
        return absdiff + 1
    else
        return self:sequence():length() - absdiff + 1
    end
end

f_mt.text = function(self)
    if not self:parted() then
        local math = require('math')
        local min = math.min(self:start(), self:stop())
        local max = math.max(self:start(), self:stop())
        local text = self:sequence():sub(min, max)
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
        return x + seq:length()
    elseif x >= seq:length() then
        return x - seq:length()
    else
        return x
    end
end

f_mt.is_subfragment_of = function(self, source)
    assert(self:sequence() == source:sequence())
    if not source:has(self:start())
            or not source:has(self:stop()) then
        return false
    end
    if not source:parted() and not self:parted() then
        return true
    elseif source:length() == source:sequence():length() then
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
            point = fix_coord(self:sequence(), point)
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
    start2 = fix_coord(self:sequence(), start2)
    stop2 = fix_coord(self:sequence(), stop2)
    local f = Fragment(self:sequence(), start2, stop2, ori2)
    assert(f:is_subfragment_of(self))
    return f
end

f_mt.common = function(self, other)
    if self:parted() then
        local a, b = self:parts()
        return a:common(other) + b:common(other)
    end
    if other:parted() then
        local a, b = other:parts()
        return self:common(a) + self:common(b)
    end
    local math = require('math')
    local self_min = math.min(self:start(), self:stop())
    local self_max = math.max(self:start(), self:stop())
    local other_min = math.min(other:start(), other:stop())
    local other_max = math.max(other:start(), other:stop())
    local common_min = math.max(self_min, other_min)
    local common_max = math.min(self_max, other_max)
    local common = common_max - common_min + 1
    if common < 0 then
        return 0
    else
        return common
    end
end

f_mt.sub = function(self, start, stop, ori)
    return self:subfragment(start, stop, ori):text()
end

f_mt.at = function(self, index)
    local seq_index = self:start() + index * self:ori()
    seq_index = fix_coord(self:sequence(), seq_index)
    local letter = self:sequence():at(seq_index)
    if self:ori() == 1 then
        return letter
    else
        local Sequence = require 'npge.model.Sequence'
        return Sequence.complement(letter)
    end
end

return setmetatable(Fragment, Fragment_mt)

