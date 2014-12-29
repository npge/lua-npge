
local Row = {}
local Row_mt = {}
local row_mt = {}

Row_mt.__index = Row_mt
row_mt.__index = row_mt

Row_mt.__call = function(self, text)
    assert(type(text) == 'string')
    assert(#text > 0)
    local row = {}
    row._text = text
    return setmetatable(row, row_mt)
end

row_mt.type = function(self)
    return "Row"
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

row_mt.text = function(self, fragment)
    if fragment then
        assert(type(fragment) == 'string')
        assert(#fragment == self:fragment_length())
        local result = {}
        for bp = 0, self:length() - 1 do
            local fp = self:block2fragment(bp)
            local char
            if fp ~= -1 then
                char = fragment:sub(fp + 1, fp + 1)
            else
                char = '-'
            end
            table.insert(result, char)
        end
        return table.concat(result)
    else
        local text = self._text:gsub('[^-]', 'N')
        return text
    end
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

row_mt.block2left = function(self, blockpos)
    for blockpos1 = blockpos, 0, -1 do
        local fragmentpos = self:block2fragment(blockpos1)
        if fragmentpos ~= -1 then
            return fragmentpos
        end
    end
    return -1
end

row_mt.block2right = function(self, blockpos)
    for blockpos1 = blockpos, self:length() - 1 do
        local fragmentpos = self:block2fragment(blockpos1)
        if fragmentpos ~= -1 then
            return fragmentpos
        end
    end
    return -1
end

row_mt.block2nearest = function(self, blockpos)
    for distance = 0, self:length() - 1 do
        local left = blockpos - distance
        if left >= 0 then
            local fragmentpos = self:block2fragment(left)
            if fragmentpos ~= -1 then
                return fragmentpos
            end
        end
        local right = blockpos + distance
        if right < self:length() then
            local fragmentpos = self:block2fragment(right)
            if fragmentpos ~= -1 then
                return fragmentpos
            end
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

