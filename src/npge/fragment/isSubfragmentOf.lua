-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

return function(self, source)
    assert(self:sequence() == source:sequence())
    local hasPos = require 'npge.fragment.hasPos'
    if not hasPos(source, self:start())
            or not hasPos(source, self:stop()) then
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
            local fixPosition =
                require 'npge.sequence.fixPosition'
            point = fixPosition(self:sequence(), point)
            if hasPos(self, point) and
                    not hasPos(source, point) then
                return false
            end
        end
        return true
    end
end
