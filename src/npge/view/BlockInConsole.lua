-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

return function(block)
    local names = {}
    local name2text = {}
    for fragment in block:iterFragments() do
        local name = fragment:id()
        local text = block:text(fragment)
        name2text[name] = text
        table.insert(names, name)
    end
    --
    local curses = require 'posix.curses'
    local alnbox = require 'alnbox'
    local aln = alnbox.makeAlignment(names, name2text)
    local parameters = alnbox.alignmentParameters(aln, curses)
    alnbox.runAlnbox(parameters)
end
