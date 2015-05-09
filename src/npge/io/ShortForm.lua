-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

local ShortForm = {}

-- difference dna1 -> dna2
-- position numbers in result are 0-based
function ShortForm.diff(dna1, dna2)
    local ShortForm_diff = require 'npge.cpp'.func.diff
    return ShortForm_diff(dna1, dna2)
end

-- apply difference diff to dna1 and return result
-- position numbers in difference are 0-based
function ShortForm.patch(dna1, patch)
    local ShortForm_patch = require 'npge.cpp'.func.patch
    return ShortForm_patch(dna1, patch)
end

-- returns iterator
function ShortForm.encode(blockset)
    assert(blockset:isPartition(),
        "Only a partition has short form")
    local npge = require 'npge'
    return coroutine.wrap(function()
        local buffer = {''} -- replace '' with function
        local function print(text, ...)
            text = text:gsub('\n *', ' ')
            text = text:format(...)
            table.insert(buffer, text)
        end
        local function yield(in_function)
            if in_function then
                buffer[1] = "(function()"
                table.insert(buffer, "end)()")
            end
            table.insert(buffer, ";\n")
            coroutine.yield(table.concat(buffer))
            buffer = {''}
        end
        print([[
        local not_sandbox = _G and not _G.setDescriptions
        if not_sandbox then
            local ShortForm = require 'npge.io.ShortForm'
            ShortForm.initRawLoading()
        end]])
        yield()
        --
        print("setDescriptions {")
        for seq in blockset:iterSequences() do
            print("[%q] = %q,", seq:name(), seq:description())
        end
        print("}")
        yield()
        --
        print("setLengths {")
        for seq in blockset:iterSequences() do
            print("[%q] = %d,", seq:name(), seq:length())
        end
        print("}")
        yield()
        --
        for block, name in blockset:iterBlocks() do
            local consensus = npge.block.consensus(block)
            print("addBlock{")
            print("name=%q,", name)
            print("consensus=%q,", consensus)
            print("mutations={")
            for fragment in block:iterFragments() do
                local text = block:text(fragment)
                assert(#text == #consensus)
                local diff = ShortForm.diff(consensus, text)
                print("[%q]=%s,", fragment:id(), diff)
            end
            print("}")
            print("}")
            yield('in_function')
        end
        --
        print([[
        if not_sandbox then
            local ShortForm = require 'npge.io.ShortForm'
            return ShortForm.finishRawLoading()
        end]])
        yield()
    end)
end

function ShortForm.loaderAndEnv()
    local loader = {
        seqname2description = nil,
        seqname2length = nil,
        seqname2frids = {},
        blockname2frids = {},
        frid2text = {}, -- value is {consensus, diff}
    }

    local env = {}

    function env.setDescriptions(s2d)
        s2d.__metatable = nil
        for seqname, _ in pairs(s2d) do
            assert(type(seqname) == 'string')
            loader.seqname2frids[seqname] = {}
        end
        loader.seqname2description = s2d
    end

    function env.setLengths(s2l)
        s2l.__metatable = nil
        loader.seqname2length = {}
        for seqname, length in pairs(s2l) do
            assert(type(seqname) == 'string')
            assert(type(length) == 'number')
            loader.seqname2length[seqname] = length
        end
    end

    local parseId = require 'npge.fragment.parseId'

    function env.addBlock(block_info)
        block_info.__metatable = nil
        local name = assert(block_info.name)
        local consensus = assert(block_info.consensus)
        local mutations = assert(block_info.mutations)
        assert(type(name) == 'string')
        assert(type(consensus) == 'string')
        assert(type(mutations) == 'table')
        mutations.__metatable = nil
        local frids = {}
        loader.blockname2frids[name] = frids
        for fr_id, diff in pairs(mutations) do
            assert(type(fr_id) == 'string')
            if type(diff) == 'table' then
                diff.__metatable = nil
                loader.frid2text[fr_id] = {consensus, diff}
            elseif type(diff) == 'string' then
                loader.frid2text[fr_id] = diff
            end
            local seqname = assert(parseId(fr_id), fr_id)
            table.insert(frids, fr_id)
            local s_frids = loader.seqname2frids[seqname]
            assert(s_frids)
            table.insert(s_frids, fr_id)
        end
    end

    return loader, env
end

local function getText(loader, frid)
    local value = assert(loader.frid2text[frid])
    if type(value) == 'string' then
        return value
    end
    local consensus = value[1]
    local diff = value[2]
    return ShortForm.patch(consensus, diff)
end

local function replaceParted(loader, parted, seqname)
    local parseId = require 'npge.fragment.parseId'
    local toAtgcn = require 'npge.alignment.toAtgcn'
    local frids = loader.seqname2frids[seqname]
    local frid = frids[parted]
    local _, start1, stop2, ori = assert(parseId(frid))
    local stop1 = loader.seqname2length[seqname] - 1
    local start2 = 0
    if ori == -1 then
        stop1, start2 = start2, stop1
    end
    local f = "%s_%d_%d_%d"
    local part1 = f:format(seqname, start1, stop1, ori)
    local part2 = f:format(seqname, start2, stop2, ori)
    frids[parted] = part1
    table.insert(frids, part2)
    -- texts
    local length1 = math.abs(stop1 - start1) + 1
    local text = toAtgcn(getText(loader, frid))
    loader.frid2text[part1] = text:sub(1, length1)
    loader.frid2text[part2] = text:sub(length1 + 1, #text)
end

local function makeSequenceText(loader, seqname)
    local parseId = require 'npge.fragment.parseId'
    local complement = require 'npge.alignment.complement'
    local frids = assert(loader.seqname2frids[seqname])
    local parted
    for i, frid in ipairs(frids) do
        local _, start, stop, ori = assert(parseId(frid))
        if (stop - start) * ori < 0 then
            parted = i
            break
        end
    end
    if parted then
        replaceParted(loader, parted, seqname)
    end
    table.sort(frids, function(frid_a, frid_b)
        local _, a_start, a_stop = assert(parseId(frid_a))
        local _, b_start, b_stop = assert(parseId(frid_b))
        local a_min = math.min(a_start, a_stop)
        local b_min = math.min(b_start, b_stop)
        return a_min < b_min
    end)
    local texts = {}
    for _, frid in ipairs(frids) do
        local text = getText(loader, frid)
        local _, _, _, ori = assert(parseId(frid))
        if ori == -1 then
            text = complement(text)
        end
        assert(#text > 0, frid)
        table.insert(texts, text)
    end
    local text = table.concat(texts)
    return text
end

function ShortForm.loader2blockset(loader)
    local parseId = require 'npge.fragment.parseId'
    local m = require 'npge.model'

    local seqname2seq = {}
    local seqs = {}
    local seqname2description = loader.seqname2description

    for seqname, description in pairs(seqname2description) do
        local text = makeSequenceText(loader, seqname)
        local seq = m.Sequence(seqname, text, description)
        assert(seq:length() == loader.seqname2length[seqname])
        table.insert(seqs, seq)
        seqname2seq[seqname] = seq
    end

    local blocks = {}

    for blockname, frids in pairs(loader.blockname2frids) do
        local fragments = {}
        for _, frid in ipairs(frids) do
            local text = getText(loader, frid)
            local seqname, start, stop, ori = parseId(frid)
            local seq = seqname2seq[seqname]
            local fragment = m.Fragment(seq, start, stop, ori)
            table.insert(fragments, {fragment, text})
        end
        local block = m.Block(fragments)
        blocks[blockname] = block
    end

    local bs = m.BlockSet(seqs, blocks)
    assert(bs:isPartition())
    return bs
end

-- iterator must return individual commands
-- ShortForm.encode yields exactly what is needed
function ShortForm.decode(iterator)
    local loader, env = ShortForm.loaderAndEnv()
    local sandbox = require 'npge.util.sandbox'
    for line in iterator do
        local f, err = assert(sandbox(env, line))
        f()
    end
    return ShortForm.loader2blockset(loader)
end

function ShortForm.initRawLoading()
    local loader, env = ShortForm.loaderAndEnv()
    _G.loader = loader
    _G.setDescriptions = env.setDescriptions
    _G.setLengths = env.setLengths
    _G.addBlock = env.addBlock
end

function ShortForm.finishRawLoading()
    local bs = ShortForm.loader2blockset(_G.loader)
    _G.loader = nil
    _G.setDescriptions = nil
    _G.setLengths = nil
    _G.addBlock = nil
    return bs
end

return ShortForm
