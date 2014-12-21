
local Sequence = {}

local Sequence_mt = {}
Sequence_mt.__index = Sequence_mt

Sequence_mt.__call = function(self, name, text, description)
    assert(type(name) == 'string')
    assert(type(text) == 'string')
    assert(type(description) == 'string' or
        type(description) == 'nil')
    local seq = {}
    seq._name = name
    seq._text = Sequence.to_atgcn(text)
    seq._description = description
    return setmetatable(seq, Sequence_mt)
end

Sequence_mt.to_atgcn = function(text)
    assert(type(text) == 'string')
    return text:upper()
        :gsub('[RYMKWSBVHD]', 'N')
        :gsub('[^ATGCN]', '')
end

Sequence_mt.type = function()
    return 'Sequence'
end

Sequence_mt.name = function(self)
    return self._name
end

local function get_name_part(name, number)
    local split = require 'npge.util.split'
    local parts = split(name, '&')
    if #parts == 3 then
        return parts[number]
    end
end

Sequence_mt.genome = function(self)
    return get_name_part(self._name, 1)
end

Sequence_mt.chromosome = function(self)
    return get_name_part(self._name, 2)
end

Sequence_mt.circularity = function(self)
    local circularity = get_name_part(self._name, 3)
    if circularity == 'c' or circularity == 'l' then
        return circularity
    end
end

Sequence_mt.text = function(self)
    return self._text
end

Sequence_mt.description = function(self)
    return self._description
end

Sequence_mt.size = function(self)
    return #self._text
end

Sequence_mt.at = function(self, index)
    return self._text:sub(index + 1, index + 1)
end

return setmetatable(Sequence, Sequence_mt)
