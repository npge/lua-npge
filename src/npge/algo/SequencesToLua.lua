return function(blockset)
    local wrap, yield = coroutine.wrap, coroutine.yield
    return wrap(function()
        local preamble = [[do
            local Sequence = require 'npge.model.Sequence'
            local name2seq = {}
        ]]
        yield(preamble)
        local text = "name2seq[%q] = Sequence.fromRef(%q)\n"
        for seq in blockset:iter_sequences() do
            local name = seq:name()
            local ref = assert(seq:toRef(),
                "References don't work")
            yield(text:format(name, ref))
        end
        local closing = [[
            return name2seq
        end]]
        yield(closing)
    end)
end
