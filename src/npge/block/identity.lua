local round = function(x)
    return math.floor(x + 0.5)
end

local mt = {}
mt.__index = mt

mt.__call = function(self, block)
    local ident = 0
    for bp = 0, block:length() - 1 do
        local gap, first, bad
        for fragment in block:iter_fragments() do
            local letter = block:at(fragment, bp)
            if letter == '-' then
                gap = true
            elseif first and letter ~= first then
                bad = true -- different nongap letters
                break
            else
                first = letter
            end
        end
        if not bad and not gap then
            ident = ident + 1
        elseif not bad and gap then
            ident = ident + 0.5
        end
    end
    return ident / block:length()
end

-- round to 0.001 and compare
local MULTIPLIER = 1000

mt.less = function(a, b)
    return round(a * MULTIPLIER) < round(b * MULTIPLIER)
end

mt.eq = function(a, b)
    return round(a * MULTIPLIER) == round(b * MULTIPLIER)
end

return setmetatable({}, mt)
