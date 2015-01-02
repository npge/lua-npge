
local Sequence = {}
local Sequence_mt = {}
local seq_mt = {}

Sequence_mt.__index = Sequence_mt
seq_mt.__index = seq_mt

Sequence_mt.__call = function(self, name, text, description)
    assert(type(name) == 'string')
    assert(type(text) == 'string')
    assert(type(description) == 'string' or
        type(description) == 'nil')
    local seq = {}
    seq._name = name
    seq._text = Sequence.to_atgcn(text)
    assert(#seq._text > 0)
    assert(#seq._name > 0)
    seq._description = description or ''
    return setmetatable(seq, seq_mt)
end

Sequence_mt.to_atgcn = function(text)
    assert(type(text) == 'string')
    return text:upper()
        :gsub('[RYMKWSBVHD]', 'N')
        :gsub('[^ATGCN]', '')
end

Sequence_mt.complement = function(text)
    return text:reverse():gsub('[ATGC]',
        {A='T', T='A', C='G', G='C'})
end

seq_mt.type = function()
    return 'Sequence'
end

seq_mt.name = function(self)
    return self._name
end

local function get_name_part(name, number)
    local split = require 'npge.util.split'
    local parts = split(name, '&')
    if #parts == 3 then
        return parts[number]
    end
end

seq_mt.genome = function(self)
    return get_name_part(self._name, 1)
end

seq_mt.chromosome = function(self)
    return get_name_part(self._name, 2)
end

seq_mt.circularity = function(self)
    local circularity = get_name_part(self._name, 3)
    if circularity == 'c' or circularity == 'l' then
        return circularity
    end
end

seq_mt.text = function(self)
    return self._text
end

seq_mt.sub = function(self, min, max)
    return self._text:sub(min + 1, max + 1)
end

seq_mt.description = function(self)
    return self._description
end

seq_mt.length = function(self)
    return #self._text
end

seq_mt.at = function(self, index)
    return self:sub(index, index)
end

seq_mt.tolua = function(self)
    local text = {}
    local step = 60
    for i = 0, self:length() - 1, step do
        table.insert(text, self:sub(i, i + step - 1))
    end
    text = table.concat(text, "\n")
    local lua = [[
do
    local Sequence = require 'npge.model.Sequence'
    return Sequence(%q, %q, %q)
end]]
    return lua:format(self:name(), text, self:description())
end

return setmetatable(Sequence, Sequence_mt)
