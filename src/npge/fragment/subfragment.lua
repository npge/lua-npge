return function(self, start, stop, ori)
    -- ori is related to source fragment
    local start2 = self:start() + self:ori() * start
    local stop2 = self:start() + self:ori() * stop
    local ori2 = self:ori() * ori
    local fix_position = require 'npge.sequence.fix_position'
    start2 = fix_position(self:sequence(), start2)
    stop2 = fix_position(self:sequence(), stop2)
    local Fragment = require 'npge.model.Fragment'
    local f = Fragment(self:sequence(), start2, stop2, ori2)
    local iso = require 'npge.fragment.is_subfragment_of'
    assert(iso(f, self))
    return f
end
