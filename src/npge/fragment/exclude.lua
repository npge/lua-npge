-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

local function exclude(minuend, subtrahend)
    local Fragment = require 'npge.model.Fragment'
    local common = minuend:common(subtrahend)
    if common == 0 then
        return minuend
    end
    if common == minuend:length() then
        return nil
    end
    if minuend:parted() then
        local a, b = minuend:parts()
        a = exclude(a, subtrahend)
        b = exclude(b, subtrahend)
        if not a or not b then
            return a or b
        end
        assert(a:ori() == b:ori())
        local both = Fragment(a:sequence(), a:start(),
            b:stop(), a:ori())
        if both:length() == a:length() + b:length() then
            -- join bck
            return both
        end
        -- select larger fragment
        if a:length() >= b:length() then
            return a
        else
            return b
        end
    end
    if subtrahend:parted() then
        local a, b = subtrahend:parts()
        minuend = exclude(minuend, a)
        minuend = exclude(minuend, b)
        return minuend
    end
    if minuend:ori() == -1 then
        local reverse = require 'npge.fragment.reverse'
        minuend = reverse(minuend)
        minuend = exclude(minuend, subtrahend)
        return minuend and reverse(minuend)
    end
    local s1 = math.min(subtrahend:start(), subtrahend:stop())
    local s2 = math.max(subtrahend:start(), subtrahend:stop())
    if s1 <= minuend:start() and minuend:start() <= s2 then
        return Fragment(minuend:sequence(), s2 + 1,
            minuend:stop(), minuend:ori())
    elseif s1 <= minuend:stop() and minuend:stop() <= s2 then
        return Fragment(minuend:sequence(), minuend:start(),
            s1 - 1, minuend:ori())
    else
        -- subtrahend is inside minuend
        assert(subtrahend:length() <= minuend:length())
        local f1 = Fragment(minuend:sequence(), s2 + 1,
            minuend:stop(), minuend:ori())
        local f2 = Fragment(minuend:sequence(), minuend:start(),
            s1 - 1, minuend:ori())
        if f1:length() >= f2:length() then
            return f1
        else
            return f2
        end
    end
end

return function(minuend, subtrahend)
    local result = exclude(minuend, subtrahend)
    assert(not result or result:common(subtrahend) == 0)
    assert(not result or result:common(minuend) ==
        result:length())
    return result
end
