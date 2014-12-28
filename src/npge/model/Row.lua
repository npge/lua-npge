
local Row = {}
local Row_mt = {}
local row_mt = {}

Row_mt.__index = Row_mt
row_mt.__index = row_mt

Row_mt.__call = function(self, text)
    local row = {}
    row._text = text
    return setmetatable(row, row_mt)
end

row_mt.length = function(self)
    return #self._text
end

row_mt.fragment_length = function(self)
    local text = self._text
    local size = #text
    local fragmentpos1 = 0
    for blockpos1 = 0, size - 1 do
        local char = text:sub(blockpos1 + 1, blockpos1 + 1)
        if char ~= '-' then
            fragmentpos1 = fragmentpos1 + 1
        end
    end
    return fragmentpos1
end

row_mt.block2fragment = function(self, blockpos)
    local text = self._text
    local size = #text
    assert(blockpos >= 0)
    assert(blockpos < size)
    local char = text:sub(blockpos + 1, blockpos + 1)
    if char == '-' then
        return -1
    end
    local fragmentpos1 = 0
    for blockpos1 = 0, size - 1 do
        local char = text:sub(blockpos1 + 1, blockpos1 + 1)
        if char ~= '-' then
            if blockpos1 == blockpos then
                return fragmentpos1
            end
            fragmentpos1 = fragmentpos1 + 1
        end
    end
end

row_mt.fragment2block = function(self, fragmentpos)
    local text = self._text
    local size = #text
    assert(fragmentpos >= 0)
    local fragmentpos1 = 0
    for blockpos1 = 0, size - 1 do
        local char = text:sub(blockpos1 + 1, blockpos1 + 1)
        if char ~= '-' then
            if fragmentpos1 == fragmentpos then
                return blockpos1
            end
            fragmentpos1 = fragmentpos1 + 1
        end
    end
    error("No such fragment pos in the row: " .. fragmentpos)
end

return setmetatable(Row, Row_mt)

