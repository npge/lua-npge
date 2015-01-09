return function(sequence)
    local as_lines = require 'npge.util.as_lines'
    return (">%s %s\n%s\n"):format(sequence:name(),
        sequence:description(), as_lines(sequence:text()))
end
