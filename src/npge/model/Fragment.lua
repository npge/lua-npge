-- use C version if available
local has_c, f_mt =
    pcall(require, 'npge.model.cFragment')
local Fragment_constructor
if has_c then
    Fragment_constructor = f_mt.constructor
    f_mt.constructor = nil
else
    f_mt = {}
end

local Fragment = {}
local Fragment_mt = {}

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
    if not seq:circular() then
        -- forbid parted fragments on linear sequences
        if ori == 1 then
            assert(start <= stop,
                "Found parted fragment on linear sequence")
        else
            assert(start >= stop,
                "Found parted fragment on linear sequence")
        end
    end
    if has_c then
        return Fragment_constructor(seq, start, stop, ori)
    else
        local f = {_seq=seq, _start=start,
            _stop=stop, _ori=ori}
        return setmetatable(f, f_mt)
    end
end

f_mt.type = function(self)
    return 'Fragment'
end

if not has_c then
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

    local function f_as_arr(self)
        return {self:sequence():name(), self:start(),
            self:stop(), self:ori()}
    end

    f_mt.__eq = function(self, other)
        local arrays_equal = require 'npge.util.arrays_equal'
        return arrays_equal(f_as_arr(self), f_as_arr(other))
    end

    f_mt.parted = function(self)
        local diff = self:stop() - self:start()
        -- (diff < 0 and self:ori() == 1) or ...
        return diff * self:ori() < 0
    end

    local function f_as_arr2(self)
        assert(not self:parted())
        local min = math.min(self:start(), self:stop())
        local max = math.max(self:start(), self:stop())
        return {min, max, self:ori(), self:sequence():name()}
    end

    f_mt.__lt = function(self, other)
        local arrays_less = require 'npge.util.arrays_less'
        return arrays_less(f_as_arr2(self), f_as_arr2(other))
    end
end

f_mt.id = function(self)
    return ("%s_%s_%s_%s"):format(
        self:sequence():name(),
        self:start(),
        self:stop(),
        self:ori())
end

f_mt.__tostring = function(self)
    local text = 'Fragment %s of length %d'
    text = text:format(self:id(), self:length())
    if self:parted() then
        text = text .. ' (parted)'
    end
    return text
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
    local absdiff = math.abs(self:stop() - self:start())
    if not self:parted() then
        return absdiff + 1
    else
        return self:sequence():length() - absdiff + 1
    end
end

f_mt.text = function(self)
    if not self:parted() then
        local min = math.min(self:start(), self:stop())
        local max = math.max(self:start(), self:stop())
        local text = self:sequence():sub(min, max)
        if self:ori() == 1 then
            return text
        else
            local C = require 'npge.alignment.complement'
            return C(text)
        end
    else
        local a, b = self:parts()
        return a:text() .. b:text()
    end
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

return setmetatable(Fragment, Fragment_mt)
