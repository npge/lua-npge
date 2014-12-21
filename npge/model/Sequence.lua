
local Sequence = {}

local Sequence_mt = {}
Sequence_mt.__index = Sequence_mt

Sequence_mt.to_atgcn = function(text)
    assert(type(text) == 'string')
    return text:upper()
        :gsub('[RYMKWSBVHD]', 'N')
        :gsub('[^ATGCN]', '')
end

Sequence_mt.__call = function(self, name, text, description)
    assert(type(name) == 'string')
    assert(type(text) == 'string')
    assert(type(description) == 'string' or
        type(description) == 'nil')
    local mt = {}
    mt.type = function()
        return 'Sequence'
    end
    mt.name = function()
        return name
    end
    local split = require 'npge.util.split'
    local parts = split(name, '&')
    local genome, chromosome, circularity
    if #parts == 3 then
        genome, chromosome, circularity = unpack(parts)
    end
    if circularity ~= 'c' and circularity ~= 'l' then
        circularity = nil
    end
    mt.genome = function() return genome end
    mt.chromosome = function() return chromosome end
    mt.circularity = function() return circularity end
    text = Sequence.to_atgcn(text)
    mt.text = function() return text end
    mt.description = function() return description end
    mt.size = function() return #text end
    mt.at = function(self, index)
        return text:sub(index + 1, index + 1)
    end
    mt.__index = mt
    return setmetatable({}, mt)
end

return setmetatable(Sequence, Sequence_mt)
