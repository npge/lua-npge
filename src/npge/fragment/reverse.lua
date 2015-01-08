return function(fragment)
    local Fragment = require 'npge.model.Fragment'
    return Fragment(fragment:sequence(),
        fragment:stop(), fragment:start(), -(fragment:ori()))
end
