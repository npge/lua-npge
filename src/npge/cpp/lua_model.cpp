/*
 * NPG-explorer, Nucleotide PanGenome explorer
 * Copyright (C) 2012-2015 Boris Nagaev
 *
 * See the LICENSE file for terms of use.
 */

#include <cstdlib>
#include <cassert>
#include <memory>
#include <boost/scoped_array.hpp>

#define LUA_LIB
#include <lua.hpp>

#include "model.hpp"
#include "throw_assert.hpp"

using namespace lnpge;

#define LUA_CALL_WRAPPED(f) \
    int results = f(L); \
    if (results == -1) { \
        return lua_error(L); \
    } else { \
        return results; \
    }

template <typename T>
T& fromLua(lua_State* L, int index, const char* mt_name) {
    void* v = luaL_checkudata(L, index, mt_name);
    T* p = reinterpret_cast<T*>(v);
    return *p;
}

template <typename T, typename P>
void toLua(lua_State* L, const T& t,
           const char* mt_name, const char* cache_name) {
    if (!t) {
        // empty shared pointer
        lua_pushnil(L);
        return;
    }
    // check in cache
    // http://lua-users.org/lists/lua-l/2007-01/msg00128.html
    P* p = const_cast<P*>(t.get());
    lua_getfield(L, LUA_REGISTRYINDEX, cache_name);
    lua_pushlightuserdata(L, p);
    lua_rawget(L, -2);
    if (lua_type(L, -1) != LUA_TNIL) {
        // re-push existing userdata
        lua_remove(L, -2); // remove cache table from stack
    } else {
        lua_pop(L, 1); // nil
        // make new userdata
        void* v = lua_newuserdata(L, sizeof(T));
        new (v) T(t);
        luaL_getmetatable(L, mt_name);
        assert(lua_type(L, -1) == LUA_TTABLE);
        lua_setmetatable(L, -2);
        // add to cache
        lua_pushlightuserdata(L, p); // key
        lua_pushvalue(L, -2); // value
        lua_rawset(L, -4);
        lua_remove(L, -2); // remove cache table from stack
    }
}

static SequencePtr& lua_toseq(lua_State* L, int index) {
    return fromLua<SequencePtr>(L, index, "npge_Sequence");
}

static void lua_pushseq(lua_State* L,
                        const SequencePtr& seq) {
    toLua<SequencePtr, Sequence>(L, seq,
            "npge_Sequence", "npge_Sequence_cache");
}

static FragmentPtr& lua_tofr(lua_State* L, int index) {
    return fromLua<FragmentPtr>(L, index, "npge_Fragment");
}

static void lua_pushfr(lua_State* L, const FragmentPtr& fr) {
    toLua<FragmentPtr, Fragment>(L, fr,
            "npge_Fragment", "npge_Fragment_cache");
}

static BlockPtr& lua_toblock(lua_State* L, int index) {
    return fromLua<BlockPtr>(L, index, "npge_Block");
}

static void lua_pushblock(lua_State* L,
                          const BlockPtr& block) {
    return toLua<BlockPtr, Block>(L, block,
            "npge_Block", "npge_Block_cache");
}

static BlockSetPtr& lua_tobs(lua_State* L, int index) {
    return fromLua<BlockSetPtr>(L, index, "npge_BlockSet");
}

static void lua_pushbs(lua_State* L, const BlockSetPtr& bs) {
    return toLua<BlockSetPtr, BlockSet>(L, bs,
            "npge_BlockSet", "npge_BlockSet_cache");
}

////////

int lua_Sequence_impl(lua_State *L) {
    size_t name_size, text_size;
    const char* name = luaL_checklstring(L, 1, &name_size);
    const char* text = luaL_checklstring(L, 2, &text_size);
    const char* description = "";
    size_t description_size = 0;
    if (lua_gettop(L) >= 3 && lua_type(L, 3) == LUA_TSTRING) {
        description = luaL_checklstring(L, 3,
                &description_size);
    }
    SequencePtr s;
    try {
        s = Sequence::make(name, description, text, text_size);
        lua_pushseq(L, s);
        return 1;
    } catch (std::exception& e) {
        lua_pushstring(L, e.what());
        return -1;
    }
}

int lua_Sequence(lua_State *L) {
    LUA_CALL_WRAPPED(lua_Sequence_impl);
}

int lua_Sequence_gc(lua_State *L) {
    SequencePtr& seq = lua_toseq(L, 1);
    seq.reset();
    return 0;
}

int lua_Sequence_type(lua_State *L) {
    lua_pushstring(L, "Sequence");
    return 1;
}

int lua_Sequence_name(lua_State *L) {
    const SequencePtr& seq = lua_toseq(L, 1);
    const std::string& name = seq->name();
    lua_pushlstring(L, name.c_str(), name.size());
    return 1;
}

int lua_Sequence_description(lua_State *L) {
    const SequencePtr& seq = lua_toseq(L, 1);
    const std::string& description = seq->description();
    lua_pushlstring(L, description.c_str(),
                    description.size());
    return 1;
}

int lua_Sequence_genome(lua_State *L) {
    const SequencePtr& seq = lua_toseq(L, 1);
    std::string genome = seq->genome();
    if (!genome.empty()) {
        lua_pushlstring(L, genome.c_str(), genome.size());
    } else {
        lua_pushnil(L);
    }
    return 1;
}

int lua_Sequence_chromosome(lua_State *L) {
    const SequencePtr& seq = lua_toseq(L, 1);
    std::string chr = seq->chromosome();
    if (!chr.empty()) {
        lua_pushlstring(L, chr.c_str(), chr.size());
    } else {
        lua_pushnil(L);
    }
    return 1;
}

int lua_Sequence_circular(lua_State *L) {
    const SequencePtr& seq = lua_toseq(L, 1);
    int circular = seq->circular();
    lua_pushboolean(L, circular);
    return 1;
}

int lua_Sequence_text(lua_State *L) {
    const SequencePtr& seq = lua_toseq(L, 1);
    const std::string& text = seq->text();
    lua_pushlstring(L, text.c_str(), text.size());
    return 1;
}

int lua_Sequence_length(lua_State *L) {
    const SequencePtr& seq = lua_toseq(L, 1);
    lua_pushinteger(L, seq->length());
    return 1;
}

int lua_Sequence_sub_impl(lua_State *L) {
    const SequencePtr& seq = lua_toseq(L, 1);
    int min = luaL_checkint(L, 2);
    int max = luaL_checkint(L, 3);
    try {
        ASSERT_LTE(0, min);
        ASSERT_LTE(min, max);
        ASSERT_LT(max, seq->length());
    } catch (std::exception& e) {
        lua_pushstring(L, e.what());
        return -1;
    }
    int len = max - min + 1;
    const std::string& text = seq->text();
    const char* slice = text.c_str() + min;
    lua_pushlstring(L, slice, len);
    return 1;
}

int lua_Sequence_sub(lua_State *L) {
    LUA_CALL_WRAPPED(lua_Sequence_sub_impl);
}

int lua_Sequence_tostring(lua_State *L) {
    const SequencePtr& seq = lua_toseq(L, 1);
    std::string repr = seq->tostring();
    lua_pushlstring(L, repr.c_str(), repr.size());
    return 1;
}

int lua_Sequence_eq(lua_State *L) {
    const SequencePtr& a = lua_toseq(L, 1);
    const SequencePtr& b = lua_toseq(L, 2);
    int eq = ((*a) == (*b));
    lua_pushboolean(L, eq);
    return 1;
}

static const luaL_Reg Sequence_methods[] = {
    {"__gc", lua_Sequence_gc},
    {"type", lua_Sequence_type},
    {"name", lua_Sequence_name},
    {"description", lua_Sequence_description},
    {"genome", lua_Sequence_genome},
    {"chromosome", lua_Sequence_chromosome},
    {"circular", lua_Sequence_circular},
    {"text", lua_Sequence_text},
    {"length", lua_Sequence_length},
    {"sub", lua_Sequence_sub},
    {"__tostring", lua_Sequence_tostring},
    {"__eq", lua_Sequence_eq},
    {NULL, NULL}
};

int lua_Fragment_impl(lua_State *L) {
    const SequencePtr& seq = lua_toseq(L, 1);
    int start = luaL_checkint(L, 2);
    int stop = luaL_checkint(L, 3);
    int ori = luaL_checkint(L, 4);
    try {
        lua_pushfr(L, Fragment::make(seq, start, stop, ori));
        return 1;
    } catch (std::exception& e) {
        lua_pushstring(L, e.what());
        return -1;
    }
}

int lua_Fragment(lua_State *L) {
    LUA_CALL_WRAPPED(lua_Fragment_impl);
}

int lua_Fragment_gc(lua_State *L) {
    FragmentPtr& fragment = lua_tofr(L, 1);
    fragment.reset();
    return 0;
}

int lua_Fragment_type(lua_State *L) {
    lua_pushstring(L, "Fragment");
    return 1;
}

int lua_Fragment_sequence(lua_State *L) {
    const FragmentPtr& fragment = lua_tofr(L, 1);
    lua_pushseq(L, fragment->sequence());
    return 1;
}

int lua_Fragment_start(lua_State *L) {
    const FragmentPtr& fragment = lua_tofr(L, 1);
    lua_pushinteger(L, fragment->start());
    return 1;
}

int lua_Fragment_stop(lua_State *L) {
    const FragmentPtr& fragment = lua_tofr(L, 1);
    lua_pushinteger(L, fragment->stop());
    return 1;
}

int lua_Fragment_ori(lua_State *L) {
    const FragmentPtr& fragment = lua_tofr(L, 1);
    lua_pushinteger(L, fragment->ori());
    return 1;
}

int lua_Fragment_parted(lua_State *L) {
    const FragmentPtr& fragment = lua_tofr(L, 1);
    lua_pushboolean(L, fragment->parted());
    return 1;
}

int lua_Fragment_length(lua_State *L) {
    const FragmentPtr& fragment = lua_tofr(L, 1);
    lua_pushinteger(L, fragment->length());
    return 1;
}

int lua_Fragment_id(lua_State *L) {
    const FragmentPtr& fragment = lua_tofr(L, 1);
    std::string id = fragment->id();
    lua_pushlstring(L, id.c_str(), id.length());
    return 1;
}

int lua_Fragment_parts_impl(lua_State *L) {
    const FragmentPtr& fragment = lua_tofr(L, 1);
    try {
        TwoFragments two = fragment->parts();
        lua_pushfr(L, two.first);
        lua_pushfr(L, two.second);
        return 2;
    } catch (std::exception& e) {
        lua_pushstring(L, e.what());
        return -1;
    }
}

int lua_Fragment_parts(lua_State *L) {
    LUA_CALL_WRAPPED(lua_Fragment_parts_impl);
}

int lua_Fragment_text(lua_State *L) {
    const FragmentPtr& fragment = lua_tofr(L, 1);
    std::string text = fragment->text();
    lua_pushlstring(L, text.c_str(), text.length());
    return 1;
}

int lua_Fragment_tostring(lua_State *L) {
    const FragmentPtr& fragment = lua_tofr(L, 1);
    std::string repr = fragment->tostring();
    lua_pushlstring(L, repr.c_str(), repr.size());
    return 1;
}

int lua_Fragment_common(lua_State *L) {
    const FragmentPtr& a = lua_tofr(L, 1);
    const FragmentPtr& b = lua_tofr(L, 2);
    lua_pushinteger(L, a->common(*b));
    return 1;
}

int lua_Fragment_eq(lua_State *L) {
    const FragmentPtr& a = lua_tofr(L, 1);
    const FragmentPtr& b = lua_tofr(L, 2);
    lua_pushboolean(L, (*a) == (*b));
    return 1;
}

int lua_Fragment_lt_impl(lua_State *L) {
    const FragmentPtr& a = lua_tofr(L, 1);
    const FragmentPtr& b = lua_tofr(L, 2);
    try {
        lua_pushboolean(L, (*a) < (*b));
        return 1;
    } catch (std::exception& e) {
        lua_pushstring(L, e.what());
        return -1;
    }
}

int lua_Fragment_lt(lua_State *L) {
    LUA_CALL_WRAPPED(lua_Fragment_lt_impl);
}

static const luaL_Reg Fragment_methods[] = {
    {"__gc", lua_Fragment_gc},
    {"type", lua_Fragment_type},
    {"sequence", lua_Fragment_sequence},
    {"start", lua_Fragment_start},
    {"stop", lua_Fragment_stop},
    {"ori", lua_Fragment_ori},
    {"parted", lua_Fragment_parted},
    {"length", lua_Fragment_length},
    {"id", lua_Fragment_id},
    {"parts", lua_Fragment_parts},
    {"text", lua_Fragment_text},
    {"common", lua_Fragment_common},
    {"__tostring", lua_Fragment_tostring},
    {"__eq", lua_Fragment_eq},
    {"__lt", lua_Fragment_lt},
    {NULL, NULL}
};

static bool hasRows(lua_State* L, int index) {
    return lua_type(L, -1) == LUA_TTABLE &&
           lua_objlen(L, -1) == 2;
}

// Block({fragment1, fragment2, ...})
int lua_Block_impl(lua_State *L) {
    luaL_argcheck(L, lua_gettop(L) >= 1, 1,
                  "Provide list of fragments to Block()");
    luaL_argcheck(L, lua_type(L, 1) == LUA_TTABLE, 1,
                  "Provide list of fragments to Block()");
    int nrows = lua_objlen(L, 1);
    luaL_argcheck(L, nrows >= 1, 1,
                  "Empty block is not allowed");
    lua_rawgeti(L, 1, 1); // first fragment
    bool has_rows = hasRows(L, -1);
    lua_pop(L, 1); // first fragment
    if (has_rows) {
        // check all
        for (int i = 0; i < nrows; i++) {
            lua_rawgeti(L, 1, i + 1); // {fragment, row}
            luaL_argcheck(L, hasRows(L, -1), 1,
                          "Provide {fragment, row}");
            lua_rawgeti(L, -1, 1); // fragment
            lua_tofr(L, -1);
            lua_pop(L, 1); // fragment
            lua_rawgeti(L, -1, 2); // row
            size_t s;
            luaL_checklstring(L, -1, &s);
            lua_pop(L, 2); // row, {fragment, row}
        }
        // now fill
        Fragments fragments(nrows);
        CStrings rows(nrows);
        for (int i = 0; i < nrows; i++) {
            lua_rawgeti(L, 1, i + 1); // {fragment, row}
            lua_rawgeti(L, -1, 1); // fragment
            fragments[i] = lua_tofr(L, -1);
            lua_pop(L, 1); // fragment
            lua_rawgeti(L, -1, 2); // row
            size_t s;
            const char* t = luaL_checklstring(L, -1, &s);
            rows[i] = CString(t, s);
            lua_pop(L, 2); // row, {fragment, row}
        }
        try {
            BlockPtr block = Block::make(fragments, rows);
            lua_pushblock(L, block);
            return 1;
        } catch (std::exception& e) {
            lua_pushstring(L, e.what());
            return -1;
        }
    } else {
        // check
        for (int i = 0; i < nrows; i++) {
            lua_rawgeti(L, 1, i + 1); // fragment
            lua_tofr(L, -1);
            lua_pop(L, 1); // fragment
        }
        // now fill
        Fragments fragments(nrows);
        for (int i = 0; i < nrows; i++) {
            lua_rawgeti(L, 1, i + 1); // fragment
            fragments[i] = lua_tofr(L, -1);
            lua_pop(L, 1); // fragment
        }
        // must not throw
        BlockPtr block = Block::make(fragments);
        lua_pushblock(L, block);
        return 1;
    }
}

int lua_Block(lua_State *L) {
    LUA_CALL_WRAPPED(lua_Block_impl);
}

int lua_Block_gc(lua_State *L) {
    BlockPtr& block = lua_toblock(L, 1);
    block.reset();
    return 0;
}

int lua_Block_type(lua_State *L) {
    lua_pushstring(L, "Block");
    return 1;
}

int lua_Block_length(lua_State *L) {
    const BlockPtr& block = lua_toblock(L, 1);
    lua_pushinteger(L, block->length());
    return 1;
}

int lua_Block_size(lua_State *L) {
    const BlockPtr& block = lua_toblock(L, 1);
    lua_pushinteger(L, block->size());
    return 1;
}

int lua_Block_text_impl(lua_State *L) {
    const BlockPtr& block = lua_toblock(L, 1);
    const FragmentPtr& fragment = lua_tofr(L, 2);
    try {
        const std::string& text = block->text(fragment);
        lua_pushlstring(L, text.c_str(), text.length());
        return 1;
    } catch (std::exception& e) {
        lua_pushstring(L, e.what());
        return -1;
    }
}

int lua_Block_text(lua_State *L) {
    LUA_CALL_WRAPPED(lua_Block_text_impl);
}

int lua_Block_fragments(lua_State *L) {
    const BlockPtr& block = lua_toblock(L, 1);
    const Fragments& fragments = block->fragments();
    int n = fragments.size();
    lua_createtable(L, n, 0);
    for (int i = 0; i < n; i++) {
        const FragmentPtr& fragment = fragments[i];
        lua_pushfr(L, fragment);
        lua_rawseti(L, -2, i + 1);
    }
    return 1;
}

// first upvalue: block
// second upvalue: index of fragment
static int Block_iterator(lua_State *L) {
    const BlockPtr& b = lua_toblock(L, lua_upvalueindex(1));
    int index = lua_tointeger(L, lua_upvalueindex(2));
    if (index < b->size()) {
        lua_pushfr(L, b->fragments()[index]);
        lua_pushinteger(L, index + 1);
        lua_replace(L, lua_upvalueindex(2));
        return 1;
    } else {
        return 0;
    }
}

int lua_Block_iterFragments(lua_State *L) {
    const BlockPtr& block = lua_toblock(L, 1);
    lua_pushvalue(L, 1); // upvalue 1 (block)
    lua_pushinteger(L, 0); // upvalue 2 (index)
    lua_pushcclosure(L, Block_iterator, 2);
    return 1;
}

int lua_Block_block2fragment_impl(lua_State *L) {
    const BlockPtr& block = lua_toblock(L, 1);
    const FragmentPtr& fragment = lua_tofr(L, 2);
    int blockpos = luaL_checkint(L, 3);
    try {
        int fp = block->block2fragment(fragment, blockpos);
        lua_pushinteger(L, fp);
        return 1;
    } catch (std::exception& e) {
        lua_pushstring(L, e.what());
        return -1;
    }
}

int lua_Block_block2fragment(lua_State *L) {
    LUA_CALL_WRAPPED(lua_Block_block2fragment_impl);
}

int lua_Block_block2right_impl(lua_State *L) {
    const BlockPtr& block = lua_toblock(L, 1);
    const FragmentPtr& fragment = lua_tofr(L, 2);
    int blockpos = luaL_checkint(L, 3);
    try {
        int fp = block->block2right(fragment, blockpos);
        lua_pushinteger(L, fp);
        return 1;
    } catch (std::exception& e) {
        lua_pushstring(L, e.what());
        return -1;
    }
}

int lua_Block_block2right(lua_State *L) {
    LUA_CALL_WRAPPED(lua_Block_block2right_impl);
}

int lua_Block_block2left_impl(lua_State *L) {
    const BlockPtr& block = lua_toblock(L, 1);
    const FragmentPtr& fragment = lua_tofr(L, 2);
    int blockpos = luaL_checkint(L, 3);
    try {
        int fp = block->block2left(fragment, blockpos);
        lua_pushinteger(L, fp);
        return 1;
    } catch (std::exception& e) {
        lua_pushstring(L, e.what());
        return -1;
    }
}

int lua_Block_block2left(lua_State *L) {
    LUA_CALL_WRAPPED(lua_Block_block2left_impl);
}

int lua_Block_tostring(lua_State *L) {
    const BlockPtr& block = lua_toblock(L, 1);
    std::string repr = block->tostring();
    lua_pushlstring(L, repr.c_str(), repr.size());
    return 1;
}

int lua_Block_eq(lua_State *L) {
    const BlockPtr& a = lua_toblock(L, 1);
    const BlockPtr& b = lua_toblock(L, 2);
    lua_pushboolean(L, (*a) == (*b));
    return 1;
}

static const luaL_Reg Block_methods[] = {
    {"__gc", lua_Block_gc},
    {"type", lua_Block_type},
    {"size", lua_Block_size},
    {"length", lua_Block_length},
    {"text", lua_Block_text},
    {"fragments", lua_Block_fragments},
    {"iter_fragments", lua_Block_iterFragments},
    {"block2fragment", lua_Block_block2fragment},
    {"block2left", lua_Block_block2left},
    {"block2right", lua_Block_block2right},
    {"__tostring", lua_Block_tostring},
    {"__eq", lua_Block_eq},
    {NULL, NULL}
};

//////////

// BlockSet(BlockSet, {sequences}, {blocks})
int lua_BlockSet_impl(lua_State *L) {
    luaL_argcheck(L, lua_gettop(L) >= 3, 2,
                  "call BlockSet({sequences}, {blocks})");
    luaL_argcheck(L, lua_type(L, 2) == LUA_TTABLE, 2,
                  "call BlockSet({sequences}, {blocks})");
    luaL_argcheck(L, lua_type(L, 3) == LUA_TTABLE, 3,
                  "call BlockSet({sequences}, {blocks})");
    int nseqs = lua_objlen(L, 2);
    int nblocks = lua_objlen(L, 3);
    // check all arguments are convertible to target types
    for (int i = 0; i < nseqs; i++) {
        lua_rawgeti(L, 2, i + 1); // sequence
        lua_toseq(L, -1);
        lua_pop(L, 1);
    }
    for (int i = 0; i < nblocks; i++) {
        lua_rawgeti(L, 3, i + 1); // block
        lua_toblock(L, -1);
        lua_pop(L, 1);
    }
    // now fill
    Sequences seqs(nseqs);
    for (int i = 0; i < nseqs; i++) {
        lua_rawgeti(L, 2, i + 1); // sequence
        seqs[i] = lua_toseq(L, -1);
        lua_pop(L, 1);
    }
    Blocks blocks(nblocks);
    for (int i = 0; i < nblocks; i++) {
        lua_rawgeti(L, 3, i + 1); // block
        blocks[i] = lua_toblock(L, -1);
        lua_pop(L, 1);
    }
    try {
        BlockSetPtr bs = BlockSet::make(seqs, blocks);
        lua_pushbs(L, bs);
        return 1;
    } catch (std::exception& e) {
        lua_pushstring(L, e.what());
        return -1;
    }
}

int lua_BlockSet(lua_State *L) {
    LUA_CALL_WRAPPED(lua_BlockSet_impl);
}

int lua_BlockSet_gc(lua_State *L) {
    BlockSetPtr& bs = lua_tobs(L, 1);
    bs.reset();
    return 0;
}

int lua_BlockSet_type(lua_State *L) {
    lua_pushstring(L, "BlockSet");
    return 1;
}

int lua_BlockSet_size(lua_State *L) {
    const BlockSetPtr& bs = lua_tobs(L, 1);
    lua_pushinteger(L, bs->size());
    return 1;
}

int lua_BlockSet_sameSequences(lua_State *L) {
    const BlockSetPtr& a = lua_tobs(L, 1);
    const BlockSetPtr& b = lua_tobs(L, 2);
    lua_pushboolean(L, a->sameSequences(*b));
    return 1;
}

int lua_BlockSet_cmp(lua_State *L) {
    const BlockSetPtr& a = lua_tobs(L, 1);
    const BlockSetPtr& b = lua_tobs(L, 2);
    std::pair<bool, std::string> p = a->cmp(*b);
    lua_pushboolean(L, p.first);
    if (p.first) {
        return 1;
    } else {
        lua_pushlstring(L, p.second.c_str(), p.second.size());
        return 2;
    }
}

int lua_BlockSet_eq(lua_State *L) {
    const BlockSetPtr& a = lua_tobs(L, 1);
    const BlockSetPtr& b = lua_tobs(L, 2);
    lua_pushboolean(L, *a == *b);
    return 1;
}

int lua_BlockSet_isPartition(lua_State *L) {
    const BlockSetPtr& bs = lua_tobs(L, 1);
    lua_pushboolean(L, bs->isPartition());
    return 1;
}

int lua_BlockSet_blocks(lua_State *L) {
    const BlockSetPtr& bs = lua_tobs(L, 1);
    const Blocks& blocks = bs->blocks();
    int n = blocks.size();
    lua_createtable(L, n, 0);
    for (int i = 0; i < n; i++) {
        const BlockPtr& block = blocks[i];
        lua_pushblock(L, block);
        lua_rawseti(L, -2, i + 1);
    }
    return 1;
}

// first upvalue: blockset
// second upvalue: index of block
static int BlockSet_blocksIterator(lua_State *L) {
    const BlockSetPtr& bs = lua_tobs(L, lua_upvalueindex(1));
    int index = lua_tointeger(L, lua_upvalueindex(2));
    if (index < bs->size()) {
        lua_pushblock(L, bs->blocks()[index]);
        lua_pushinteger(L, index + 1);
        lua_replace(L, lua_upvalueindex(2));
        return 1;
    } else {
        return 0;
    }
}

int lua_BlockSet_iterBlocks(lua_State *L) {
    const BlockSetPtr& bs = lua_tobs(L, 1);
    lua_pushvalue(L, 1); // upvalue 1 (blockset)
    lua_pushinteger(L, 0); // upvalue 2 (index)
    lua_pushcclosure(L, BlockSet_blocksIterator, 2);
    return 1;
}

int lua_BlockSet_sequences(lua_State *L) {
    const BlockSetPtr& bs = lua_tobs(L, 1);
    const Sequences& seqs = bs->sequences();
    int n = seqs.size();
    lua_createtable(L, n, 0);
    for (int i = 0; i < n; i++) {
        const SequencePtr& seq = seqs[i];
        lua_pushseq(L, seq);
        lua_rawseti(L, -2, i + 1);
    }
    return 1;
}

// first upvalue: blockset
// second upvalue: index of sequence
static int BlockSet_seqsIterator(lua_State *L) {
    const BlockSetPtr& bs = lua_tobs(L, lua_upvalueindex(1));
    int index = lua_tointeger(L, lua_upvalueindex(2));
    const Sequences& seqs = bs->sequences();
    if (index < seqs.size()) {
        lua_pushseq(L, seqs[index]);
        lua_pushinteger(L, index + 1);
        lua_replace(L, lua_upvalueindex(2));
        return 1;
    } else {
        return 0;
    }
}

int lua_BlockSet_iterSequences(lua_State *L) {
    const BlockSetPtr& bs = lua_tobs(L, 1);
    lua_pushvalue(L, 1); // upvalue 1 (blockset)
    lua_pushinteger(L, 0); // upvalue 2 (index)
    lua_pushcclosure(L, BlockSet_seqsIterator, 2);
    return 1;
}

int lua_BlockSet_fragments_impl(lua_State *L) {
    const BlockSetPtr& bs = lua_tobs(L, 1);
    const SequencePtr& seq = lua_toseq(L, 2);
    try {
        const Fragments& parts = bs->parts(seq);
        int n = parts.size();
        lua_createtable(L, n, 0);
        for (int i = 0; i < n; i++) {
            const FragmentPtr& part = parts[i];
            const FragmentPtr& f = bs->parentOrFragment(part);
            lua_pushfr(L, f);
            lua_rawseti(L, -2, i + 1);
        }
        return 1;
    } catch (std::exception& e) {
        lua_pushstring(L, e.what());
        return -1;
    }
}

int lua_BlockSet_fragments(lua_State *L) {
    LUA_CALL_WRAPPED(lua_BlockSet_fragments_impl);
}

// first upvalue: blockset
// second upvalue: sequence
// third upvalue: index of sequence
// iterator returns fragment and subfragment (part)
// for non-parted fragments fragment = subfragment
static int BlockSet_fragmentsIterator(lua_State *L) {
    const BlockSetPtr& bs = lua_tobs(L, lua_upvalueindex(1));
    const SequencePtr& s = lua_toseq(L, lua_upvalueindex(2));
    int index = lua_tointeger(L, lua_upvalueindex(3));
    const Fragments& parts = bs->parts(s);
    if (index < parts.size()) {
        const FragmentPtr& part = parts[index];
        const FragmentPtr& fr = bs->parentOrFragment(part);
        lua_pushfr(L, fr);
        lua_pushfr(L, part);
        lua_pushinteger(L, index + 1);
        lua_replace(L, lua_upvalueindex(3));
        return 2;
    } else {
        return 0;
    }
}

int lua_BlockSet_iterFragments_impl(lua_State *L) {
    const BlockSetPtr& bs = lua_tobs(L, 1);
    const SequencePtr& seq = lua_toseq(L, 2);
    try {
        // test
        const Fragments& parts = bs->parts(seq);
        lua_pushvalue(L, 1); // upvalue 1 (blockset)
        lua_pushvalue(L, 2); // upvalue 2 (sequence)
        lua_pushinteger(L, 0); // upvalue 3 (index)
        lua_pushcclosure(L, BlockSet_fragmentsIterator, 3);
        return 1;
    } catch (std::exception& e) {
        lua_pushstring(L, e.what());
        return -1;
    }
}

int lua_BlockSet_iterFragments(lua_State *L) {
    LUA_CALL_WRAPPED(lua_BlockSet_iterFragments_impl);
}

int lua_BlockSet_hasSequence(lua_State *L) {
    const BlockSetPtr& bs = lua_tobs(L, 1);
    const SequencePtr& seq = lua_toseq(L, 2);
    lua_pushboolean(L, bs->hasSequence(seq));
    return 1;
}

int lua_BlockSet_sequenceByName(lua_State *L) {
    const BlockSetPtr& bs = lua_tobs(L, 1);
    size_t name_size;
    const char* name = luaL_checklstring(L, 2, &name_size);
    std::string name_str(name, name_size);
    SequencePtr seq = bs->sequenceByName(name);
    lua_pushseq(L, seq);
    return 1;
}

int lua_BlockSet_blockByFragment(lua_State *L) {
    const BlockSetPtr& bs = lua_tobs(L, 1);
    const FragmentPtr& fr = lua_tofr(L, 2);
    BlockPtr block = bs->blockByFragment(fr);
    lua_pushblock(L, block);
    return 1;
}

int lua_BlockSet_overlappingFragments(lua_State *L) {
    const BlockSetPtr& bs = lua_tobs(L, 1);
    const FragmentPtr& fr = lua_tofr(L, 2);
    Fragments overlapping = bs->overlapping(fr);
    int n = overlapping.size();
    lua_createtable(L, n, 0);
    for (int i = 0; i < n; i++) {
        const FragmentPtr& f = overlapping[i];
        lua_pushfr(L, f);
        lua_rawseti(L, -2, i + 1);
    }
    return 1;
}

int lua_BlockSet_next_impl(lua_State *L) {
    const BlockSetPtr& bs = lua_tobs(L, 1);
    const FragmentPtr& fr = lua_tofr(L, 2);
    try {
        FragmentPtr next = bs->next(fr);
        lua_pushfr(L, next);
        return 1;
    } catch (std::exception& e) {
        lua_pushstring(L, e.what());
        return -1;
    }
}

int lua_BlockSet_next(lua_State *L) {
    LUA_CALL_WRAPPED(lua_BlockSet_next_impl);
}

int lua_BlockSet_prev_impl(lua_State *L) {
    const BlockSetPtr& bs = lua_tobs(L, 1);
    const FragmentPtr& fr = lua_tofr(L, 2);
    try {
        FragmentPtr prev = bs->prev(fr);
        lua_pushfr(L, prev);
        return 1;
    } catch (std::exception& e) {
        lua_pushstring(L, e.what());
        return -1;
    }
}

int lua_BlockSet_prev(lua_State *L) {
    LUA_CALL_WRAPPED(lua_BlockSet_prev_impl);
}

int lua_BlockSet_tostring(lua_State *L) {
    const BlockSetPtr& bs = lua_tobs(L, 1);
    std::string repr = bs->tostring();
    lua_pushlstring(L, repr.c_str(), repr.size());
    return 1;
}

int lua_BlockSet_toRef(lua_State *L) {
    const BlockSetPtr& bs = lua_tobs(L, 1);
    int increase_count = lua_toboolean(L, 2);
    if (increase_count) {
        using namespace boost;
        intrusive_ptr_add_ref(bs.get());
    }
    char buffer[100];
    sprintf(buffer, "BlockSet.fromRef(%p)", bs.get());
    lua_pushstring(L, buffer);
    return 1;
}

int lua_BlockSet_fromRef(lua_State *L) {
    size_t len;
    const char* ref = luaL_checklstring(L, 1, &len);
    int decrease_count = lua_toboolean(L, 2);
    const BlockSet* raw_bs;
    sscanf(ref, "BlockSet.fromRef(%p)", &raw_bs);
    BlockSetPtr bs(raw_bs); // adds reference count
    lua_pushbs(L, bs);
    if (decrease_count) {
        using namespace boost;
        intrusive_ptr_release(bs.get());
    }
    return 1;
}

static const luaL_Reg BlockSet_methods[] = {
    {"__gc", lua_BlockSet_gc},
    {"type", lua_BlockSet_type},
    {"size", lua_BlockSet_size},
    {"same_sequences", lua_BlockSet_sameSequences},
    {"cmp", lua_BlockSet_cmp},
    {"is_partition", lua_BlockSet_isPartition},
    {"blocks", lua_BlockSet_blocks},
    {"iter_blocks", lua_BlockSet_iterBlocks},
    {"fragments", lua_BlockSet_fragments},
    {"iter_fragments", lua_BlockSet_iterFragments},
    {"sequences", lua_BlockSet_sequences},
    {"iter_sequences", lua_BlockSet_iterSequences},
    {"has_sequence", lua_BlockSet_hasSequence},
    {"sequence_by_name", lua_BlockSet_sequenceByName},
    {"block_by_fragment", lua_BlockSet_blockByFragment},
    {"overlapping_fragments",
        lua_BlockSet_overlappingFragments},
    {"next", lua_BlockSet_next},
    {"prev", lua_BlockSet_prev},
    {"__tostring", lua_BlockSet_tostring},
    {"__eq", lua_BlockSet_eq},
    {NULL, NULL}
};

// table "model" is on stack index -1
// model.BlockSet is function
// replaces model.BlockSet with callable table
// with member fromRef
void registerBlockSetFromRef(lua_State* L) {
    lua_newtable(L); // callable table BlockSet
    lua_newtable(L); // metatable of callable table
    lua_getfield(L, -3, "BlockSet");
    lua_setfield(L, -2, "__call"); // mt.__call = BlockSet
    lua_setmetatable(L, -2);
    lua_pushcfunction(L, lua_BlockSet_toRef);
    lua_setfield(L, -2, "toRef");
    lua_pushcfunction(L, lua_BlockSet_fromRef);
    lua_setfield(L, -2, "fromRef");
    lua_setfield(L, -2, "BlockSet");
}

/////////

typedef boost::scoped_array<char> Buffer;

int lua_toAtgcn(lua_State* L) {
    size_t text_size;
    const char* text = luaL_checklstring(L, 1, &text_size);
    if (text_size == 0) {
        lua_pushlstring(L, text, text_size);
        return 1;
    }
    Buffer buffer(new char[text_size]);
    int size = toAtgcn(buffer.get(), text, text_size);
    lua_pushlstring(L, buffer.get(), size);
    return 1;
}

int lua_toAtgcnAndGap(lua_State* L) {
    size_t text_size;
    const char* text = luaL_checklstring(L, 1, &text_size);
    if (text_size == 0) {
        lua_pushlstring(L, text, text_size);
        return 1;
    }
    Buffer buffer(new char[text_size]);
    int size = toAtgcnAndGap(buffer.get(), text, text_size);
    lua_pushlstring(L, buffer.get(), size);
    return 1;
}

int lua_complement(lua_State* L) {
    size_t text_size;
    const char* text = luaL_checklstring(L, 1, &text_size);
    if (text_size == 0) {
        lua_pushlstring(L, text, text_size);
        return 1;
    }
    Buffer buffer(new char[text_size]);
    int size = complement(buffer.get(), text, text_size);
    lua_pushlstring(L, buffer.get(), size);
    return 1;
}

// -1 is module "model"
static void registerType(lua_State *L,
                         const char* type_name,
                         const char* mt_name,
                         const char* cache_name,
                         lua_CFunction constructor,
                         const luaL_Reg* methods) {
    // cache
    lua_newtable(L);
    lua_newtable(L); // mt of cache
    lua_pushliteral(L, "v");
    lua_setfield(L, -2, "__mode");
    lua_setmetatable(L, -2);
    lua_setfield(L, LUA_REGISTRYINDEX, cache_name);
    // metatable for instance
    luaL_newmetatable(L, mt_name);
    lua_pushvalue(L, -1);
    lua_setfield(L, -2, "__index"); // mt.__index = mt
    luaL_register(L, NULL, methods);
    lua_pop(L, 1); // metatable of instance
    // constructor
    lua_pushcfunction(L, constructor);
    lua_setfield(L, -2, type_name);
}

static const luaL_Reg free_functions[] = {
    {"toAtgcn", lua_toAtgcn},
    {"toAtgcnAndGap", lua_toAtgcnAndGap},
    {"complement", lua_complement},
    {NULL, NULL}
};

extern "C" {
int luaopen_npge_cpp(lua_State *L) {
    lua_newtable(L);
    registerType(L, "Sequence", "npge_Sequence",
                 "npge_Sequence_cache",
                 lua_Sequence, Sequence_methods);
    registerType(L, "Fragment", "npge_Fragment",
                 "npge_Fragment_cache",
                 lua_Fragment, Fragment_methods);
    registerType(L, "Block", "npge_Block",
                 "npge_Block_cache",
                 lua_Block, Block_methods);
    registerType(L, "BlockSet", "npge_BlockSet",
                 "npge_BlockSet_cache",
                 lua_BlockSet, BlockSet_methods);
    registerBlockSetFromRef(L);
    luaL_register(L, NULL, free_functions);
    return 1;
}

}
