return function(self, source)
    assert(self:sequence() == source:sequence())
    local has_pos = require 'npge.fragment.has_pos'
    if not has_pos(source, self:start())
            or not has_pos(source, self:stop()) then
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
            local fix_position =
                require 'npge.sequence.fix_position'
            point = fix_position(self:sequence(), point)
            if has_pos(self, point) and
                    not has_pos(source, point) then
                return false
            end
        end
        return true
    end
end
