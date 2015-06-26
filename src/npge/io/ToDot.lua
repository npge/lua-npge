-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

return function(blockset)
    local nodes = {}
    local fragment2node = {}
    local edges = {}
    -- nodes (fragments)
    for sequence in blockset:iterSequences() do
        for fragment in blockset:iterFragments(sequence) do
            if not fragment2node[fragment] then -- parted
                local block = blockset:blockByFragment(fragment)
                local name = blockset:nameByBlock(block)
                local node = {name = name}
                fragment2node[fragment] = node
                table.insert(nodes, node)
            end
        end
    end
    -- edges to prev
    for sequence in blockset:iterSequences() do
        local seen_fragments = {}
        for fragment in blockset:iterFragments(sequence) do
            if not seen_fragments[fragment] then
                seen_fragments[fragment] = true
                local prev = blockset:prev(fragment)
                local edge = {}
                local node1 = fragment2node[fragment]
                local node2 = fragment2node[prev]
                table.insert(edges, {node1, node2, edge})
            end
        end
    end
    -- edges to other fragments of a block
    for block in blockset:iterBlocks() do
        local fragments = block:fragments()
        table.sort(fragments, function(f1, f2)
            local genome1 = f1:sequence():genome()
            local genome2 = f2:sequence():genome()
            return genome1 < genome2
        end)
        for i = 2, #fragments do
            local f1 = fragments[i-1]
            local f2 = fragments[i]
            -- connect f1 and f2
            local edge = {}
            local node1 = fragment2node[f1]
            local node2 = fragment2node[f2]
            table.insert(edges, {node1, node2, edge})
        end
    end
    local T = require 'treelua'
    local graph = T.Graph(nodes, edges)
    return T.toDot(graph)
end
