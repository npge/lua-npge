return function(blockset)
    for seq in blockset:iter_sequences() do
        local prev, prev_parent
        for parent, part in blockset:iter_fragments(seq) do
            if prev and prev:common(part) > 0 then
                return true, prev_parent, parent
            end
            prev = part
            prev_parent = parent
        end
    end
    return false
end
