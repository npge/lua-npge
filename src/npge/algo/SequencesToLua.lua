return function(blockset)
    local wrap, yield = coroutine.wrap, coroutine.yield
    return wrap(function()
        yield [[do
            local Sequence = require 'npge.model.Sequence'
            local name2seq = {}
        ]]
        local text = "name2seq[%q] = Sequence.fromRef(%q)\n"
        for seq in blockset:iter_sequences() do
            local name = seq:name()
            local ref = assert(seq:toRef(),
                "References don't work")
            yield(text:format(name, ref))
        end
        yield [[
            return name2seq
        end]]
    end)
end
