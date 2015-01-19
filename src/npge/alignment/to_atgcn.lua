return function(text)
    assert(type(text) == 'string')
    text = text:upper()
        :gsub('[RYMKWSBVHD]', 'N')
        :gsub('[^ATGCN]', '')
    return text
end
