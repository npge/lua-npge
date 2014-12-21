
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

return setmetatable(Fragment, Fragment_mt)

