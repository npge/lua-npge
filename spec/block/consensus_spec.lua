-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

describe("block.consensus", function()
    it("finds consensus of block (100%)", function()
        local model = require 'npge.model'
        local s = model.Sequence("s", "ATAT")
        local f = model.Fragment(s, 0, 3, 1)
        local b = model.Block({f, f})
        local consensus = require 'npge.block.consensus'
        assert.equal(consensus(b), "ATAT")
    end)

    local check_consensus = function(rows, expected_consensus)
        it("gets consensus " .. expected_consensus, function()
            local model = require 'npge.model'
            local for_block = {}
            for _, row in ipairs(rows) do
                local s = model.Sequence('name', row)
                local f = model.Fragment(s, 0,
                    s:length() - 1, 1)
                table.insert(for_block, {f, row})
            end
            local b = model.Block(for_block)
            local consensus = require 'npge.block.consensus'
            assert.equal(consensus(b), expected_consensus)
        end)
    end

    check_consensus({
       "ATAT",
    }, "ATAT")

    check_consensus({
       "ATAT",
       "AT-T",
       "AT-T",
    }, "ATAT")

    check_consensus({
       "A",
       "T",
       "G",
    }, "A")

    check_consensus({
       "A",
       "N",
       "N",
    }, "A")

    check_consensus({
       "A",
       "T",
       "T",
    }, "T")

    check_consensus({
       "T",
       "T",
       "A",
    }, "T")

    check_consensus({
       "T",
       "A",
       "T",
    }, "T")

    check_consensus({
       "T",
       "A",
    }, "A")

    check_consensus({
[[GCAATGGCGTCAGAGTTTCCATAGTACAATGAATCAGAAGGGAAACAATAAG
TTTTTTAACCATTATACGGTCATGGTATGAACTGAGTTTTCATAAA-GCA]],
[[GCAATGGCATCAGAGTTTCCATAGTACAATGAATTGGAAGTGAAACAATAAG
TTTTTTCACCATTATACAGTTATGGTATGAACTGGGTCTTCATAAAAAAA]],
[[GCAATGGCATCAGAGTTTCCATAGTACAATGAATTGGAAGTGAAACAATCAG
TTTTTTCACCATTATACAGTTATGGTATGAACTGGGTCTTCATAAAAAAA]],
[[GCAATGGCGTCAGAGTTTCCATAGTATAATAAATTGGAAGGAAAACAATTAG
TTTTTTAACTATTATGCAGTCATGGTATGAACTTGGTCTCCATCAAAGCA]],
},
"GCAATGGCATCAGAGTTTCCATAGTACAATGAATTGGAAGTGAAACAATAAG" ..
"TTTTTTAACCATTATACAGTTATGGTATGAACTGGGTCTTCATAAAAAAA")
end)
