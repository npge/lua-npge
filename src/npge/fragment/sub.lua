return function(self, start, stop, ori)
    local subfragment = require 'npge.fragment.subfragment'
    return subfragment(self, start, stop, ori):text()
end

