return function(self, index)
    local seq_index = self:start() + index * self:ori()
    local fix_position = require 'npge.sequence.fix_position'
    seq_index = fix_position(self:sequence(), seq_index)
    local letter = self:sequence():at(seq_index)
    if self:ori() == 1 then
        return letter
    else
        local C = require 'npge.alignment.complement'
        return C(letter)
    end
end
