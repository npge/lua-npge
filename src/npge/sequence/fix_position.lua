return function(seq, x)
    if x < 0 then
        assert(seq:circular())
        return x + seq:length()
    elseif x >= seq:length() then
        assert(seq:circular())
        return x - seq:length()
    else
        return x
    end
end
