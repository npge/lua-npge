return function(text)
    text = text:reverse():gsub('[ATGC]',
        {A='T', T='A', C='G', G='C'})
    return text
end
