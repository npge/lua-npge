-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

local overlaps

-- ori is inherited from self
-- results are ordered by self
-- 0 <= #results <= 2
function overlaps(self, other)
    if self:sequence() ~= other:sequence() then
        return {}
    end
    if other:ori() ~= self:ori() then
        local reverse = require 'npge.fragment.reverse'
        other = reverse(other)
    end
    if self:parted() then
        local p1, p2 = self:parts()
        local o1 = overlaps(p1, other)
        local o2 = overlaps(p2, other)
        if #o1 >= 1 and #o2 >= 1 then
            -- try to join parts of parted
            local Fragment = require 'npge.model.Fragment'
            local seq = self:sequence()
            local ori = self:ori()
            local f1 = o1[#o1]
            local f2 = o2[1]
            local g = Fragment(seq, f1:start(), f2:stop(), ori)
            if g:length() == f1:length() + f2:length() then
                assert(g:parted())
                -- extend
                o1[#o1] = nil
                o2[1] = g
            end
            local concat = require 'npge.util.concatArrays'
            return concat(o1, o2)
        end
    end
    if other:parted() then
        assert(not self:parted())
        local p2, p1 = other:parts()
        -- in reverse order, because parted!
        local o1 = overlaps(self, p1)
        local o2 = overlaps(self, p2)
        assert(#o1 <= 1)
        assert(#o2 <= 1)
        local concat = require 'npge.util.concatArrays'
        return concat(o1, o2)
    end
    local self_min = math.min(self:start(), self:stop())
    local self_max = math.max(self:start(), self:stop())
    local other_min = math.min(other:start(), other:stop())
    local other_max = math.max(other:start(), other:stop())
    local common_min = math.max(self_min, other_min)
    local common_max = math.min(self_max, other_max)
    if common_min <= common_max then
        local Fragment = require 'npge.model.Fragment'
        local seq = self:sequence()
        if self:ori() == 1 then
            return {Fragment(seq, common_min, common_max, 1)}
        else
            return {Fragment(seq, common_max, common_min, -1)}
        end
    end
    return {}
end

return overlaps
