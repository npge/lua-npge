-- use C version if available
local has_c, cSequenceText =
    pcall(require, 'npge.model.cSequenceText')

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
    local to_atgcn = require 'npge.alignment.to_atgcn'
    text = to_atgcn(text)
    assert(#text > 0, "No empty sequences allowed")
    assert(#seq._name > 0, "No unknown sequences allowed")
    seq._description = description or ''
    if has_c then
        seq._text = cSequenceText(text)
    else
        seq._text = text
    end
    return setmetatable(seq, seq_mt)
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

seq_mt.circular = function(self)
    local circularity = get_name_part(self._name, 3)
    return circularity == 'c'
end

if has_c then
    seq_mt.text = function(self)
        local length = self._text:length()
        return self._text:sub(0, length - 1)
    end
else
    seq_mt.text = function(self)
        return self._text
    end
end

local function seq_as_arr(self)
    return {self:name(), self:description()}
end

seq_mt.__eq = function(self, other)
    local arrays_equal = require 'npge.util.arrays_equal'
    return arrays_equal(seq_as_arr(self), seq_as_arr(other))
        and self._text == other._text
end

seq_mt.__tostring = function(self)
    local text = 'Sequence %s of length %d'
    return text:format(self:name(), self:length())
end

seq_mt.sub = function(self, min, max)
    assert(min >= 0)
    assert(min <= max)
    assert(max <= self:length())
    if has_c then
        return self._text:sub(min, max)
    else
        return self._text:sub(min + 1, max + 1)
    end
end

seq_mt.description = function(self)
    return self._description
end

if has_c then
    seq_mt.length = function(self)
        return self._text:length()
    end
else
    seq_mt.length = function(self)
        return #self._text
    end
end

seq_mt.at = function(self, index)
    return self:sub(index, index)
end

return setmetatable(Sequence, Sequence_mt)
