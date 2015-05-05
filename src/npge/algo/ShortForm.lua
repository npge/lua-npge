-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

local ShortForm = {}

-- difference dna1 -> dna2
-- position numbers in result are 0-based
ShortForm.diff = function(dna1, dna2)
    assert(#dna1 == #dna2)
    local base2pos = {}
    for i = 1, #dna1 do
        local base1 = dna1:sub(i, i)
        local base2 = dna2:sub(i, i)
        if base1 ~= base2 then
            if not base2pos[base2] then
                base2pos[base2] = {}
            end
            table.insert(base2pos[base2], i - 1)
        end
    end
    local base2pos1 = {}
    for base, pos in pairs(base2pos) do
        local code = "[%q]={%s}" -- {['-'] = {1,2,3}}
        if base ~= '-' then
            code = "%s={%s}" -- {A = {1,2,3}}
        end
        code = code:format(base, table.concat(pos, ","))
        table.insert(base2pos1, code)
    end
    local diff = table.concat(base2pos1, ",")
    if #diff < #dna2 then
        return ("{%s}"):format(diff)
    else
        -- difference is larger than target string
        return ("%q"):format(dna2)
    end
end

-- apply difference diff to dna1 and return result
-- position numbers in difference are 0-based
ShortForm.patch = function(dna1, patch)
    if type(patch) == 'string' then
        -- difference is larger than target string
        return patch
    end
    local list = {}
    for i = 1, #dna1 do
        list[i] = dna1:sub(i, i)
    end
    for base, positions in pairs(patch) do
        for _, i in ipairs(positions) do
            assert(i >= 0)
            assert(i < #dna1)
            list[i + 1] = base
        end
    end
    return table.concat(list)
end

-- returns iterator
ShortForm.encode = function(blockset)
    assert(blockset:isPartition(),
        "Only a partition has short form")
    local npge = require 'npge'
    return coroutine.wrap(function()
        local buffer = {}
        local function print(text, ...)
            table.insert(buffer, text:format(...))
        end
        local function yield()
            table.insert(buffer, "\n")
            coroutine.yield(table.concat(buffer))
            buffer = {}
        end
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
            yield()
        end
    end)
end

-- iterator must return individual commands
-- ShortForm.encode yields exactly what is needed
ShortForm.decode = function(iterator)
    local seqname2description
    local seqname2length
    local seqname2frids = {}
    local frid2text = {}
    local blockname2frids = {}

    local parseId = require 'npge.fragment.parseId'

    local env = {
        setDescriptions = function(...)
            seqname2description = ...
            for seqname, _ in pairs(seqname2description) do
                seqname2frids[seqname] = {}
            end
        end,

        setLengths = function(...)
            seqname2length = ...
        end,

        addBlock = function(block_info)
            local name = block_info.name
            local consensus = block_info.consensus
            local mutations = block_info.mutations
            local frids = {}
            blockname2frids[name] = frids
            for fr_id, diff in pairs(mutations) do
                local text = ShortForm.patch(consensus, diff)
                local seqname = assert(parseId(fr_id), fr_id)
                frid2text[fr_id] = text
                table.insert(frids, fr_id)
                local s_frids = assert(seqname2frids[seqname])
                table.insert(s_frids, fr_id)
            end
        end
    }

    local sandbox = require 'npge.util.sandbox'
    for line in iterator do
        local f, err = assert(sandbox(env, line))
        f()
    end

    local complement = require 'npge.alignment.complement'
    local toAtgcn = require 'npge.alignment.toAtgcn'
    local m = require 'npge.model'

    local seqname2seq = {}
    local seqs = {}

    local function replaceParted(parted, seqname)
        local frids = seqname2frids[seqname]
        local frid = frids[parted]
        local _, start1, stop2, ori = assert(parseId(frid))
        local stop1 = seqname2length[seqname] - 1
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
        local text = toAtgcn(frid2text[frid])
        frid2text[part1] = text:sub(1, length1)
        frid2text[part2] = text:sub(length1 + 1, #text)
    end

    for seqname, description in pairs(seqname2description) do
        local frids = assert(seqname2frids[seqname])
        local parted
        for i, frid in ipairs(frids) do
            local _, start, stop, ori = assert(parseId(frid))
            if (stop - start + 1) * ori < 0 then
                parted = i
                break
            end
        end
        if parted then
            replaceParted(parted, seqname)
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
            local text = assert(frid2text[frid])
            local _, _, _, ori = assert(parseId(frid))
            if ori == -1 then
                text = complement(text)
            end
            table.insert(texts, text)
        end
        local text = table.concat(texts)
        local seq = m.Sequence(seqname, text, description)
        assert(seq:length() == seqname2length[seqname])
        table.insert(seqs, seq)
        seqname2seq[seqname] = seq
    end

    local blocks = {}

    for blockname, frids in pairs(blockname2frids) do
        local fragments = {}
        for _, frid in ipairs(frids) do
            local text = frid2text[frid]
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

return ShortForm
