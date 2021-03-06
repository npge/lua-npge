-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2016 Boris Nagaev
-- See the LICENSE file for terms of use.

-- short form = consensuses + mutations
-- short form is sufficient to recover full form

describe("npge.io.ShortForm", function()
    it("makes short form of a partition", function()
        local ShortForm = require 'npge.io.ShortForm'
        local npge = require 'npge'
        local s = npge.model.Sequence("s1&c&c", "ATGATGATG")
        local f1 = npge.model.Fragment(s, 2, 4, 1)
        local f2 = npge.model.Fragment(s, 5, 6, 1)
        local f3 = npge.model.Fragment(s, 1, 7, -1)
        local block = npge.model.Block({f1, f2, f3})
        local bs = npge.model.BlockSet({s}, {block})
        local bs1 = ShortForm.decode(ShortForm.encode(bs))
        assert.equal(bs1, bs)
    end)

    it("iterator provides strings", function()
        local ShortForm = require 'npge.io.ShortForm'
        local npge = require 'npge'
        local s = npge.model.Sequence("s1&c&c", "ATGATGATG")
        local f1 = npge.model.Fragment(s, 2, 4, 1)
        local f2 = npge.model.Fragment(s, 5, 6, 1)
        local f3 = npge.model.Fragment(s, 1, 7, -1)
        local block = npge.model.Block({f1, f2, f3})
        local bs = npge.model.BlockSet({s}, {block})
        local line1 = ShortForm.encode(bs)()
        assert.equal(type(line1), "string")
    end)

    it("raw Lua code is loadable", function()
        local ShortForm = require 'npge.io.ShortForm'
        local npge = require 'npge'
        local s = npge.model.Sequence("s1&c&c", "ATGATGATG")
        local f1 = npge.model.Fragment(s, 2, 4, 1)
        local f2 = npge.model.Fragment(s, 5, 6, 1)
        local f3 = npge.model.Fragment(s, 1, 7, -1)
        local block = npge.model.Block({f1, f2, f3})
        local bs = npge.model.BlockSet({s}, {block})
        local readIt = require 'npge.util.readIt'
        local lua = readIt(ShortForm.encode(bs))
        local loadstring = require 'npge.util.loadstring'
        local bs1 = loadstring(lua)()
        assert.equal(bs1, bs)
    end)

    it("adding blocks on undeclared sequences fails",
    function()
        local ShortForm = require 'npge.io.ShortForm'
        assert.has_error(function()
            ShortForm.decode(coroutine.wrap(function()
                coroutine.yield [[
                addBlock {
                    name="1",
                    consensus="GATA",
                    mutations={
                        ["s1&c&c_1_7_-1"]="ATCA",
                        ["s1&c&c_2_4_1"]="GAT-",
                        ["s1&c&c_5_6_1"]="GA--",}}
                ]]
            end))
        end)
    end)

    it("adding sequence with bad description fails",
    function()
        local ShortForm = require 'npge.io.ShortForm'
        assert.has_error(function()
            ShortForm.decode(coroutine.wrap(function()
                coroutine.yield [[
                setDescriptions {["s1&c&c"] = {},}
                setLengths {["s1&c&c"] = 4,}
                addBlock {
                    name="1",
                    consensus="GATA",
                    mutations={
                        ["s1&c&c_0_3_1"]={},
                    }
                }
                ]]
            end))
        end)
    end)

    it("adding sequence with bad description fails (control)",
    function()
        local ShortForm = require 'npge.io.ShortForm'
        ShortForm.decode(coroutine.wrap(function()
            coroutine.yield [[
            setDescriptions {["s1&c&c"] = "",}
            setLengths {["s1&c&c"] = 4,}
            addBlock {
                name="1",
                consensus="GATA",
                mutations={
                    ["s1&c&c_0_3_1"]={},
                }
            }
            ]]
        end))
    end)

    it("adding sequence with bad sequence length fails",
    function()
        local ShortForm = require 'npge.io.ShortForm'
        assert.has_error(function()
            ShortForm.decode(coroutine.wrap(function()
                coroutine.yield [[
                setDescriptions {["s1&c&c"] = "",}
                setLengths {["s1&c&c"] = -1,}
                addBlock {
                    name="1",
                    consensus="GATA",
                    mutations={
                        ["s1&c&c_0_3_1"]={},
                    }
                }
                ]]
            end))
        end)
        assert.has_error(function()
            ShortForm.decode(coroutine.wrap(function()
                coroutine.yield [[
                setDescriptions {["s1&c&c"] = "",}
                setLengths {["s1&c&c"] = {},}
                addBlock {
                    name="1",
                    consensus="GATA",
                    mutations={
                        ["s1&c&c_0_3_1"]={},
                    }
                }
                ]]
            end))
        end)
    end)

    it("adding blocks with bad patches fails", function()
        local ShortForm = require 'npge.io.ShortForm'
        assert.has_error(function()
            ShortForm.decode(coroutine.wrap(function()
                coroutine.yield [[
                setDescriptions {["s1&c&c"] = "",}
                setLengths {["s1&c&c"] = 9,}
                addBlock {
                    name="1",
                    consensus="GATA",
                    mutations={
                        ["s1&c&c_1_7_-1"]={A={-1,1,2}},
                        ["s1&c&c_2_4_1"]="GAT-",
                        ["s1&c&c_5_6_1"]="GA--",}}
                ]]
            end))
        end)
        assert.has_error(function()
            ShortForm.decode(coroutine.wrap(function()
                coroutine.yield [[
                setDescriptions {["s1&c&c"] = "",}
                setLengths {["s1&c&c"] = 9,}
                addBlock {
                    name="1",
                    consensus="GATA",
                    mutations={
                        ["s1&c&c_1_7_-1"]={A={0,1,2,10}},
                        ["s1&c&c_2_4_1"]="GAT-",
                        ["s1&c&c_5_6_1"]="GA--",}}
                ]]
            end))
        end)
        assert.has_error(function()
            ShortForm.decode(coroutine.wrap(function()
                coroutine.yield [[
                setDescriptions {["s1&c&c"] = "",}
                setLengths {["s1&c&c"] = 9,}
                addBlock {
                    name="1",
                    consensus="GATA",
                    mutations={
                        ["s1&c&c_1_7_-1"]="A",
                        ["s1&c&c_2_4_1"]="GAT-",
                        ["s1&c&c_5_6_1"]="GA--",}}
                ]]
            end))
        end)
        assert.has_error(function()
            ShortForm.decode(coroutine.wrap(function()
                coroutine.yield [[
                setDescriptions {["s1&c&c"] = "",}
                setLengths {["s1&c&c"] = 9,}
                addBlock {
                    name="1",
                    consensus="GATA",
                    mutations={
                        ["s1&c&c_1_7_-1"]=1,
                        ["s1&c&c_2_4_1"]="GAT-",
                        ["s1&c&c_5_6_1"]="GA--",}}
                ]]
            end))
        end)
        assert.has_error(function()
            ShortForm.decode(coroutine.wrap(function()
                coroutine.yield [[
                setDescriptions {["s1&c&c"] = "",}
                setLengths {["s1&c&c"] = 9,}
                addBlock {
                    name="1",
                    consensus="GATA",
                    mutations={
                        ["s1&c&c_1_7_-1"]={AA={1,2,3}},
                        ["s1&c&c_2_4_1"]="GAT-",
                        ["s1&c&c_5_6_1"]="GA--",}}
                ]]
            end))
        end)
        assert.has_error(function()
            ShortForm.decode(coroutine.wrap(function()
                coroutine.yield [[
                setDescriptions {["s1&c&c"] = "",}
                setLengths {["s1&c&c"] = 9,}
                addBlock {
                    name="1",
                    consensus="GATA",
                    mutations={
                        ["s1&c&c_1_7_-1"]={A="AA"},
                        ["s1&c&c_2_4_1"]="GAT-",
                        ["s1&c&c_5_6_1"]="GA--",}}
                ]]
            end))
        end)
        assert.has_error(function()
            ShortForm.decode(coroutine.wrap(function()
                coroutine.yield [[
                setDescriptions {["s1&c&c"] = "",}
                setLengths {["s1&c&c"] = 9,}
                addBlock {
                    name="1",
                    consensus="GATA",
                    mutations={
                        ["s1&c&c_1_7_-1"]={A={'A',2,3},
                        ["s1&c&c_2_4_1"]="GAT-",
                        ["s1&c&c_5_6_1"]="GA--",}}
                ]]
            end))
        end)
        assert.has_error(function()
            ShortForm.decode(coroutine.wrap(function()
                coroutine.yield [[
                setDescriptions {["s1&c&c"] = "",}
                setLengths {["s1&c&c"] = 9,}
                addBlock {
                    name="1",
                    consensus="GATA",
                    mutations={
                        ["s1&c&c_1_7_-1"]={[1]={2,3},
                        ["s1&c&c_2_4_1"]="GAT-",
                        ["s1&c&c_5_6_1"]="GA--",}}
                ]]
            end))
        end)
    end)

    it("reads direct fragments of length 1", function()
        local ShortForm = require 'npge.io.ShortForm'
        local npge = require 'npge'
        local s = npge.model.Sequence("s1&c&c", "ATGATGATG")
        local f1 = npge.model.Fragment(s, 2, 5, 1)
        local f2 = npge.model.Fragment(s, 6, 6, 1)
        local f3 = npge.model.Fragment(s, 1, 7, -1)
        local block = npge.model.Block({f1, f2, f3})
        local bs = npge.model.BlockSet({s}, {block})
        local bs1 = ShortForm.decode(ShortForm.encode(bs))
        assert.equal(bs1, bs)
    end)

    it("reads reverse fragments of length 1", function()
        local ShortForm = require 'npge.io.ShortForm'
        local npge = require 'npge'
        local s = npge.model.Sequence("s1&c&c", "ATGATGATG")
        local f1 = npge.model.Fragment(s, 2, 5, 1)
        local f2 = npge.model.Fragment(s, 6, 6, -1)
        local f3 = npge.model.Fragment(s, 1, 7, -1)
        local block = npge.model.Block({f1, f2, f3})
        local bs = npge.model.BlockSet({s}, {block})
        local bs1 = ShortForm.decode(ShortForm.encode(bs))
        assert.equal(bs1, bs)
    end)

    it("reads parted fragments", function()
        local ShortForm = require 'npge.io.ShortForm'
        local npge = require 'npge'
        local s = npge.model.Sequence("s1&c&c", "ATGATGATG")
        local f1 = npge.model.Fragment(s, 2, 6, 1)
        local f2 = npge.model.Fragment(s, 7, 1, 1)
        local block = npge.model.Block({f1, f2})
        local bs = npge.model.BlockSet({s}, {block})
        local bs1 = ShortForm.decode(ShortForm.encode(bs))
        assert.equal(bs1, bs)
    end)

    it("makes short form of the sample pangenome", function()
        local ShortForm = require 'npge.io.ShortForm'
        local readFile = require 'npge.util.readFile'
        local LoadFromLua = require 'npge.io.LoadFromLua'
        local sample = readFile('spec/sample_pangenome.lua')
        local bs = LoadFromLua(sample)()
        local bs1 = ShortForm.decode(ShortForm.encode(bs))
        assert.equal(bs1, bs)
        -- only good blocks
        local Filter = require 'npge.algo.FilterGoodBlocks'
        local good_blocks = Filter(bs)
        assert.not_equal(good_blocks, bs)
        local has_sequences = true
        local it = ShortForm.encode(good_blocks, has_sequences)
        local good_blocks1 = ShortForm.decode(it, bs)
        assert.equal(good_blocks1, good_blocks)
    end)
end)

describe("npge.io.ShortForm (diff + patch)", function()
    local function eval(diff)
        local loadstring = require 'npge.util.loadstring'
        return loadstring('return ' .. diff)()
    end

    it("returns difference between two sequences", function()
        local diff = require 'npge.cpp'.func.diff
        local patch = require 'npge.cpp'.func.patch
        assert.equal(patch("A", eval(diff("A", "T"))), "T")
        assert.equal(patch(
        "AGCTCATACTGCTTTGGGGAGCCGTTTCGACGGGCTCTGGGATAGGGAAA",
        eval(diff(
        "AGCTCATACTGCTTTGGGGAGCCGTTTCGACGGGCTCTGGGATAGGGAAA",
        "-GCTCATACTGCTTTGGGGAGCCGTTTCGACGGGCTCTGGGATAGGGAAN")
        )),
        "-GCTCATACTGCTTTGGGGAGCCGTTTCGACGGGCTCTGGGATAGGGAAN")
    end)

    it("length of returned difference <= text length + 2",
    function()
        local diff = require 'npge.cpp'.func.diff
        assert.truthy(#diff("A", "T") <= #"A" + 2)
        assert.truthy(#diff(
        "AGCTCATACTGCTTTGGGGAGCCGTTTCGACGGGCTCTGGGATAGGGAAA",
        "-GCTCATACTGCTTTGGGGAGCCGTTTCGACGGGCTCTGGGATAGGGAA-"
        ) <=
       #"AGCTCATACTGCTTTGGGGAGCCGTTTCGACGGGCTCTGGGATAGGGAAA"
        + 2)
    end)

    it("throws if text length != consensus length",
    function()
        local diff = require 'npge.cpp'.func.diff
        local patch = require 'npge.cpp'.func.patch
        assert.has_error(function()
            diff("A", "AA")
        end)
        assert.has_error(function()
            patch("A", "AA")
        end)
    end)

    it("throws if consensus length is 0",
    function()
        local diff = require 'npge.cpp'.func.diff
        local patch = require 'npge.cpp'.func.patch
        assert.has_error(function()
            diff("", "")
        end)
        assert.has_error(function()
            patch("", "")
        end)
    end)
end)
