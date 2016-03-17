/* lua-npge, Nucleotide PanGenome explorer (Lua module)
 * Copyright (C) 2014-2016 Boris Nagaev
 * See the LICENSE file for terms of use.
 */

#include <cassert>
#include <climits>
#include <cstdlib>
#include <cstring>
#include <memory>
#include <boost/scoped_array.hpp>

#define LUA_LIB
#include <lua.hpp>

#include "npge.hpp"
#include "throw_assert.hpp"

using namespace lnpge;

template<lua_CFunction F>
struct wrap {
    static int func(lua_State* L) {
        try {
            return F(L);
        } catch (std::exception& e) {
            lua_pushstring(L, e.what());
        } catch (...) {
            lua_pushliteral(L, "Unknown exception");
        }
        return lua_error(L);
    }
};

#if LUA_VERSION_NUM == 501
#define npge_rawlen lua_objlen
#else
#define npge_rawlen lua_rawlen
#endif

#if LUA_VERSION_NUM == 501
#define npge_setfuncs(L, funcs) luaL_register(L, NULL, funcs)
#else
#define npge_setfuncs(L, funcs) luaL_setfuncs(L, funcs, 0)
#endif

template <typename A>
A* newLuaArray(lua_State* L, int size) {
    void* v = lua_newuserdata(L, size * sizeof(A));
    return reinterpret_cast<A*>(v);
}

const char** toRows(lua_State* L, int index,
                    int nrows, int& length) {
    // populate rows
    const char** rows = newLuaArray<const char*>(L, nrows);
    for (int irow = 0; irow < nrows; irow++) {
        lua_rawgeti(L, index, irow + 1);
        size_t len;
        const char* row = luaL_checklstring(L, -1, &len);
        rows[irow] = row;
        if (irow == 0) {
            length = len;
        } else {
            luaL_argcheck(L, len == length, 1,
                    "All rows must be of equal length");
        }
        lua_pop(L, 1);
    }
    return rows;
}

const char** toRows(lua_State* L, int index,
                    int nrows, int*& lens) {
    const char** rows = newLuaArray<const char*>(L, nrows);
    lens = newLuaArray<int>(L, nrows);
    // populate rows
    for (int irow = 0; irow < nrows; irow++) {
        lua_rawgeti(L, index, irow + 1);
        size_t len;
        const char* row = luaL_checklstring(L, -1, &len);
        rows[irow] = row;
        lens[irow] = len;
        lua_pop(L, 1);
    }
    return rows;
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

int lua_Sequence(lua_State *L) {
    size_t name_size, text_size;
    const char* name = luaL_checklstring(L, 1, &name_size);
    const char* text = luaL_checklstring(L, 2, &text_size);
    const char* description = "";
    size_t description_size = 0;
    if (lua_gettop(L) >= 3 && lua_type(L, 3) == LUA_TSTRING) {
        description = luaL_checklstring(L, 3,
                &description_size);
    }
    SequencePtr s = Sequence::make(
        name, description, text, text_size
    );
    lua_pushseq(L, s);
    return 1;
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

int lua_Sequence_sub(lua_State *L) {
    const SequencePtr& seq = lua_toseq(L, 1);
    int min = luaL_checkinteger(L, 2);
    int max = luaL_checkinteger(L, 3);
    ASSERT_LTE(0, min);
    ASSERT_LTE(min, max);
    ASSERT_LT(max, seq->length());
    int len = max - min + 1;
    const std::string& text = seq->text();
    const char* slice = text.c_str() + min;
    lua_pushlstring(L, slice, len);
    return 1;
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

static const luaL_Reg Sequence_mt[] = {
    {"__gc", lua_Sequence_gc},
    {"__tostring", lua_Sequence_tostring},
    {"__eq", lua_Sequence_eq},
    {NULL, NULL}
};

static const luaL_Reg Sequence_methods[] = {
    {"type", lua_Sequence_type},
    {"name", lua_Sequence_name},
    {"description", lua_Sequence_description},
    {"genome", lua_Sequence_genome},
    {"chromosome", lua_Sequence_chromosome},
    {"circular", lua_Sequence_circular},
    {"text", lua_Sequence_text},
    {"length", lua_Sequence_length},
    {"sub", wrap<lua_Sequence_sub>::func},
    {NULL, NULL}
};

int lua_Fragment(lua_State *L) {
    const SequencePtr& seq = lua_toseq(L, 1);
    int start = luaL_checkinteger(L, 2);
    int stop = luaL_checkinteger(L, 3);
    int ori = luaL_checkinteger(L, 4);
    lua_pushfr(L, Fragment::make(seq, start, stop, ori));
    return 1;
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

int lua_Fragment_parts(lua_State *L) {
    const FragmentPtr& fragment = lua_tofr(L, 1);
    TwoFragments two = fragment->parts();
    lua_pushfr(L, two.first);
    lua_pushfr(L, two.second);
    return 2;
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

int lua_Fragment_lt(lua_State *L) {
    const FragmentPtr& a = lua_tofr(L, 1);
    const FragmentPtr& b = lua_tofr(L, 2);
    lua_pushboolean(L, (*a) < (*b));
    return 1;
}

static const luaL_Reg Fragment_mt[] = {
    {"__gc", lua_Fragment_gc},
    {"__tostring", lua_Fragment_tostring},
    {"__eq", lua_Fragment_eq},
    {"__lt", lua_Fragment_lt},
    {NULL, NULL}
};

static const luaL_Reg Fragment_methods[] = {
    {"type", lua_Fragment_type},
    {"sequence", lua_Fragment_sequence},
    {"start", lua_Fragment_start},
    {"stop", lua_Fragment_stop},
    {"ori", lua_Fragment_ori},
    {"parted", lua_Fragment_parted},
    {"length", lua_Fragment_length},
    {"id", lua_Fragment_id},
    {"parts", wrap<lua_Fragment_parts>::func},
    {"text", lua_Fragment_text},
    {"common", lua_Fragment_common},
    {NULL, NULL}
};

static bool hasRows(lua_State* L, int index) {
    return lua_type(L, -1) == LUA_TTABLE &&
           npge_rawlen(L, -1) == 2;
}

// Block({fragment1, fragment2, ...})
int lua_Block(lua_State *L) {
    luaL_argcheck(L, lua_gettop(L) >= 1, 1,
                  "Provide list of fragments to Block()");
    luaL_argcheck(L, lua_type(L, 1) == LUA_TTABLE, 1,
                  "Provide list of fragments to Block()");
    int nrows = npge_rawlen(L, 1);
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
            ASSERT_LTE(s, INT_MAX);
            rows[i] = CString(t, s);
            lua_pop(L, 2); // row, {fragment, row}
        }
        BlockPtr block = Block::make(fragments, rows);
        lua_pushblock(L, block);
        return 1;
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

int lua_Block_text(lua_State *L) {
    const BlockPtr& block = lua_toblock(L, 1);
    const FragmentPtr& fragment = lua_tofr(L, 2);
    const std::string& text = block->text(fragment);
    lua_pushlstring(L, text.c_str(), text.length());
    return 1;
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

int lua_Block_fragment2block(lua_State *L) {
    const BlockPtr& block = lua_toblock(L, 1);
    const FragmentPtr& fragment = lua_tofr(L, 2);
    int fp = luaL_checkinteger(L, 3);
    int bp = block->fragment2block(fragment, fp);
    lua_pushinteger(L, bp);
    return 1;
}

int lua_Block_block2fragment(lua_State *L) {
    const BlockPtr& block = lua_toblock(L, 1);
    const FragmentPtr& fragment = lua_tofr(L, 2);
    int blockpos = luaL_checkinteger(L, 3);
    int fp = block->block2fragment(fragment, blockpos);
    lua_pushinteger(L, fp);
    return 1;
}

int lua_Block_block2right(lua_State *L) {
    const BlockPtr& block = lua_toblock(L, 1);
    const FragmentPtr& fragment = lua_tofr(L, 2);
    int blockpos = luaL_checkinteger(L, 3);
    int fp = block->block2right(fragment, blockpos);
    lua_pushinteger(L, fp);
    return 1;
}

int lua_Block_block2left(lua_State *L) {
    const BlockPtr& block = lua_toblock(L, 1);
    const FragmentPtr& fragment = lua_tofr(L, 2);
    int blockpos = luaL_checkinteger(L, 3);
    int fp = block->block2left(fragment, blockpos);
    lua_pushinteger(L, fp);
    return 1;
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

int lua_Block_lt(lua_State *L) {
    const BlockPtr& a = lua_toblock(L, 1);
    const BlockPtr& b = lua_toblock(L, 2);
    lua_pushboolean(L, (*a) < (*b));
    return 1;
}

static const luaL_Reg Block_mt[] = {
    {"__gc", lua_Block_gc},
    {"__tostring", lua_Block_tostring},
    {"__eq", lua_Block_eq},
    {"__lt", lua_Block_lt},
    {NULL, NULL}
};

static const luaL_Reg Block_methods[] = {
    {"type", lua_Block_type},
    {"size", lua_Block_size},
    {"length", lua_Block_length},
    {"text", wrap<lua_Block_text>::func},
    {"fragments", lua_Block_fragments},
    {"iterFragments", lua_Block_iterFragments},
    {"fragment2block", wrap<lua_Block_fragment2block>::func},
    {"block2fragment", wrap<lua_Block_block2fragment>::func},
    {"block2right", wrap<lua_Block_block2right>::func},
    {"block2left", wrap<lua_Block_block2left>::func},
    {NULL, NULL}
};

//////////

// BlockSet(BlockSet, {sequences}, {blocks}, [names generator])
int lua_BlockSet(lua_State *L) {
    luaL_argcheck(L, lua_gettop(L) >= 3, 2,
                  "call BlockSet({sequences}, {blocks})");
    luaL_argcheck(L, lua_type(L, 2) == LUA_TTABLE, 2,
                  "call BlockSet({sequences}, {blocks})");
    luaL_argcheck(L, lua_type(L, 3) == LUA_TTABLE, 3,
                  "call BlockSet({sequences}, {blocks})");
    int nseqs = npge_rawlen(L, 2);
    // check all arguments are convertible to target types
    for (int i = 0; i < nseqs; i++) {
        lua_rawgeti(L, 2, i + 1); // sequence
        lua_toseq(L, -1);
        lua_pop(L, 1);
    }
    int nblocks = 0;
    // iterate blocks as hash
    lua_pushnil(L);  // first key
    while (lua_next(L, 3) != 0) {
        // 'key' at index -2 and 'value' at index -1
        lua_toblock(L, -1);
        // removes 'value'; keeps 'key' for next iteration
        lua_pop(L, 1);
        nblocks += 1;
    }
    // now fill
    Sequences seqs(nseqs);
    for (int i = 0; i < nseqs; i++) {
        lua_rawgeti(L, 2, i + 1); // sequence
        seqs[i] = lua_toseq(L, -1);
        lua_pop(L, 1);
    }
    // check last argument - name generator blockset
    BlockSetPtr source;
    if (lua_gettop(L) >= 4) {
        source = lua_tobs(L, 4);
    }
    Blocks blocks(nblocks);
    Strings names(nblocks);
    // iterate blocks as hash
    lua_pushnil(L);  // first key
    int i = 0;
    while (lua_next(L, 3) != 0) {
        // 'key' at index -2 and 'value' at index -1
        blocks[i] = lua_toblock(L, -1);
        if (source) {
            names[i] = source->nameByBlock(blocks[i]);
        } else {
            luaL_argcheck(L, lua_type(L, -2) == LUA_TSTRING ||
                          lua_type(L, -2) == LUA_TNUMBER, 3,
                          "key in blocks table must be "
                          "a string or an integer");
            if (lua_type(L, -2) == LUA_TSTRING) {
                size_t len;
                const char* name = lua_tolstring(L, -2, &len);
                names[i] = std::string(name, len);
            } else if (lua_type(L, -2) == LUA_TNUMBER) {
                int name = lua_tointeger(L, -2);
                names[i] = TO_S(name);
            }
        }
        // removes 'value'; keeps 'key' for next iteration
        lua_pop(L, 1);
        i += 1;
    }
    BlockSetPtr bs = BlockSet::make(seqs, blocks, names);
    lua_pushbs(L, bs);
    return 1;
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
    const char* p = a->cmp(*b);
    bool ok = (p == 0);
    lua_pushboolean(L, ok);
    if (ok) {
        return 1;
    } else {
        lua_pushstring(L, p);
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

// bs:blocks(names = false)
int lua_BlockSet_blocks(lua_State *L) {
    const BlockSetPtr& bs = lua_tobs(L, 1);
    bool names = lua_toboolean(L, 2);
    int n = bs->size();
    if (names) {
        lua_createtable(L, 0, n);
    } else {
        lua_createtable(L, n, 0);
    }
    for (int i = 0; i < n; i++) {
        const BlockPtr& block = bs->blockAt(i);
        if (names) {
            const std::string& name = bs->nameAt(i);
            lua_pushlstring(L, name.c_str(), name.size());
            lua_pushblock(L, block);
            lua_rawset(L, -3);
        } else {
            lua_pushblock(L, block);
            lua_rawseti(L, -2, i + 1);
        }
    }
    return 1;
}

int lua_BlockSet_blocksNames(lua_State *L) {
    const BlockSetPtr& bs = lua_tobs(L, 1);
    int n = bs->size();
    lua_createtable(L, n, 0);
    for (int i = 0; i < n; i++) {
        const std::string& name = bs->nameAt(i);
        lua_pushlstring(L, name.c_str(), name.size());
        lua_rawseti(L, -2, i + 1);
    }
    return 1;
}

int lua_BlockSet_blockByName(lua_State *L) {
    const BlockSetPtr& bs = lua_tobs(L, 1);
    size_t len;
    const char* name_c = luaL_checklstring(L, 2, &len);
    std::string name(name_c, len);
    BlockPtr block = bs->blockByName(name);
    lua_pushblock(L, block); // pushes nil on null ptr
    return 1;
}

int lua_BlockSet_nameByBlock(lua_State *L) {
    const BlockSetPtr& bs = lua_tobs(L, 1);
    const BlockPtr& block = lua_toblock(L, 2);
    std::string name = bs->nameByBlock(block);
    lua_pushlstring(L, name.c_str(), name.size());
    return 1;
}

int lua_BlockSet_hasBlock(lua_State *L) {
    const BlockSetPtr& bs = lua_tobs(L, 1);
    const BlockPtr& block = lua_toblock(L, 2);
    bool has_block = bs->hasBlock(block);
    lua_pushboolean(L, has_block);
    return 1;
}

// first upvalue: blockset
// second upvalue: index of block
// yields (block, name)
static int BlockSet_blocksIterator(lua_State *L) {
    const BlockSetPtr& bs = lua_tobs(L, lua_upvalueindex(1));
    int index = lua_tointeger(L, lua_upvalueindex(2));
    if (index < bs->size()) {
        lua_pushblock(L, bs->blockAt(index));
        const std::string& name = bs->nameAt(index);
        lua_pushlstring(L, name.c_str(), name.size());
        lua_pushinteger(L, index + 1);
        lua_replace(L, lua_upvalueindex(2));
        return 2;
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
    int n = bs->sequencesNumber();
    lua_createtable(L, n, 0);
    for (int i = 0; i < n; i++) {
        const SequencePtr& seq = bs->sequenceAt(i);
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
    if (index < bs->sequencesNumber()) {
        lua_pushseq(L, bs->sequenceAt(index));
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

int lua_BlockSet_iterFragments(lua_State *L) {
    const BlockSetPtr& bs = lua_tobs(L, 1);
    const SequencePtr& seq = lua_toseq(L, 2);
    // test
    const Fragments& parts = bs->parts(seq);
    lua_pushvalue(L, 1); // upvalue 1 (blockset)
    lua_pushvalue(L, 2); // upvalue 2 (sequence)
    lua_pushinteger(L, 0); // upvalue 3 (index)
    lua_pushcclosure(L, BlockSet_fragmentsIterator, 3);
    return 1;
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

int lua_BlockSet_blocksByFragment(lua_State *L) {
    const BlockSetPtr& bs = lua_tobs(L, 1);
    const FragmentPtr& fr = lua_tofr(L, 2);
    Blocks blocks = bs->blocksByFragment(fr);
    int n = blocks.size();
    lua_createtable(L, n, 0);
    for (int i = 0; i < n; i++) {
        const BlockPtr& block = blocks[i];
        lua_pushblock(L, block);
        lua_rawseti(L, -2, i + 1);
    }
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

int lua_BlockSet_next(lua_State *L) {
    const BlockSetPtr& bs = lua_tobs(L, 1);
    const FragmentPtr& fr = lua_tofr(L, 2);
    FragmentPtr next = bs->next(fr);
    lua_pushfr(L, next);
    return 1;
}

int lua_BlockSet_prev(lua_State *L) {
    const BlockSetPtr& bs = lua_tobs(L, 1);
    const FragmentPtr& fr = lua_tofr(L, 2);
    FragmentPtr prev = bs->prev(fr);
    lua_pushfr(L, prev);
    return 1;
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

static const luaL_Reg BlockSet_mt[] = {
    {"__gc", lua_BlockSet_gc},
    {"__tostring", lua_BlockSet_tostring},
    {"__eq", lua_BlockSet_eq},
    {NULL, NULL}
};

static const luaL_Reg BlockSet_methods[] = {
    {"type", lua_BlockSet_type},
    {"size", lua_BlockSet_size},
    {"sameSequences", lua_BlockSet_sameSequences},
    {"cmp", lua_BlockSet_cmp},
    {"isPartition", lua_BlockSet_isPartition},
    {"blocks", lua_BlockSet_blocks},
    {"blocksNames", lua_BlockSet_blocksNames},
    {"blockByName", lua_BlockSet_blockByName},
    {"nameByBlock", lua_BlockSet_nameByBlock},
    {"hasBlock", lua_BlockSet_hasBlock},
    {"iterBlocks", lua_BlockSet_iterBlocks},
    {"iterFragments", wrap<lua_BlockSet_iterFragments>::func},
    {"sequences", lua_BlockSet_sequences},
    {"iterSequences", lua_BlockSet_iterSequences},
    {"hasSequence", lua_BlockSet_hasSequence},
    {"sequenceByName", lua_BlockSet_sequenceByName},
    {"blockByFragment", lua_BlockSet_blockByFragment},
    {"blocksByFragment", lua_BlockSet_blocksByFragment},
    {"overlappingFragments",
        lua_BlockSet_overlappingFragments},
    {"next", wrap<lua_BlockSet_next>::func},
    {"prev", wrap<lua_BlockSet_prev>::func},
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

static int lengthsSum(const BlockPtr& a) {
    int len = 0;
    const Fragments& fragments = a->fragments();
    int size = a->size();
    for (int i = 0; i < size; i++) {
        len += fragments[i]->length();
    }
    return len;
}

// arguments: two blocks
// implementation of npge.block.better
static int lua_block_better(lua_State* L) {
    const BlockPtr& a = lua_toblock(L, 1);
    const BlockPtr& b = lua_toblock(L, 2);
    int result = (a->size() > b->size()) ||
        (a->size() == b->size() &&
         lengthsSum(a) > lengthsSum(b));
    lua_pushboolean(L, result);
    return 1;
}

static const luaL_Reg block_functions[] = {
    {"better", lua_block_better},
    {NULL, NULL}
};

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

int lua_unwindRow(lua_State *L) {
    size_t row_size, orig_size;
    const char* row = luaL_checklstring(L, 1, &row_size);
    const char* orig = luaL_checklstring(L, 2, &orig_size);
    luaL_argcheck(L, row_size >= orig_size, 1,
            "Length of row on consensus must be >= "
            "length of row on original sequence");
    int size;
    {
        Buffer buffer(new char[row_size]);
        size = unwindRow(buffer.get(), row, row_size,
                         orig, orig_size);
        if (size != -1) {
            lua_pushlstring(L, buffer.get(), size);
        }
    }
    if (size == -1) {
        return luaL_error(L, "Original and consensus rows "
                "do not match");
    }
    return 1;
}

// arguments:
// 1. Lua table with rows
// 2. start position
// 3. stop position
int lua_identity(lua_State *L) {
    int args = lua_gettop(L);
    luaL_checktype(L, 1, LUA_TTABLE);
    int nrows = npge_rawlen(L, 1);
    if (nrows == 0) {
        lua_pushnumber(L, 0);
        lua_pushnumber(L, 0);
        lua_pushnumber(L, 0);
        return 3;
    }
    int length;
    const char** rows = toRows(L, 1, nrows, length);
    if (length == 0) {
        lua_pushnumber(L, 0);
        lua_pushnumber(L, 0);
        lua_pushnumber(L, 0);
        return 3;
    }
    // start and stop
    int start = 0;
    int stop = length - 1;
    if (args >= 2) {
        start = luaL_checknumber(L, 2);
        luaL_argcheck(L, start >= 0, 2, "start >= 0");
    }
    if (args >= 3) {
        stop = luaL_checknumber(L, 3);
        luaL_argcheck(L, start <= stop, 3, "start <= stop");
        luaL_argcheck(L, stop <= length - 1, 3,
                "stop <= length - 1");
    }
    // calculate identity
    double ident = identity(rows, nrows, start, stop);
    double l = stop - start + 1;
    double result = ident / l;
    lua_pushnumber(L, result);
    lua_pushnumber(L, ident);
    lua_pushnumber(L, l);
    return 3;
}

// arguments:
// 1. Lua table with rows
int lua_consensus(lua_State *L) {
    int args = lua_gettop(L);
    luaL_checktype(L, 1, LUA_TTABLE);
    int nrows = npge_rawlen(L, 1);
    if (nrows == 0) {
        lua_pushnil(L);
        return 1;
    }
    int length;
    const char** rows = toRows(L, 1, nrows, length);
    if (length == 0) {
        lua_pushliteral(L, "");
        return 1;
    }
    // calculate consensus
    char* consensus_str = newLuaArray<char>(L, length);
    consensus(consensus_str, rows, nrows, length);
    lua_pushlstring(L, consensus_str, length);
    return 1;
}

// arguments:
// 1. consensus
// 2. text
// results:
// 1. diff's text as Lua code
int lua_ShortForm_diff(lua_State *L) {
    size_t cons_size, text_size;
    const char* cons = luaL_checklstring(L, 1, &cons_size);
    const char* text = luaL_checklstring(L, 2, &text_size);
    luaL_argcheck(L, cons_size == text_size, 1,
            "Length of text must be equal to consensus size");
    luaL_argcheck(L, cons_size >= 1, 1,
            "Length of a consensus must be >= 1");
    int length = text_size;
    char* diff = newLuaArray<char>(L, length + 2);
    int diff_len = ShortForm_diff(diff, cons, text, length);
    lua_pushlstring(L, diff, diff_len);
    return 1;
}

// arguments:
// 1. consensus
// 2. difference (a table or a string)
// results:
// 1. text
int lua_ShortForm_patch(lua_State *L) {
    size_t cons_size;
    const char* cons = luaL_checklstring(L, 1, &cons_size);
    int length = cons_size;
    luaL_argcheck(L, length >= 1, 1,
            "Length of a consensus must be >= 1");
    luaL_argcheck(L, lua_type(L, 2) == LUA_TTABLE ||
            lua_type(L, 2) == LUA_TSTRING, 2,
            "Difference must be a string or a table");
    if (lua_type(L, 2) == LUA_TSTRING) {
        // text = difference
        size_t diff_size;
        const char* diff = luaL_checklstring(L, 2, &diff_size);
        luaL_argcheck(L, diff_size == length, 2,
                "Length of difference differs from "
                "consensus length");
        lua_pushvalue(L, 2);
        return 1;
    }
    char* buffer = newLuaArray<char>(L, length);
    memcpy(buffer, cons, length);
    // iterate blocks as hash
    lua_pushnil(L);  // first key
    while (lua_next(L, 2) != 0) {
        // 'key' at index -2 and 'value' at index -1
        luaL_argcheck(L, lua_type(L, -2) == LUA_TSTRING, 2,
                "Type of base must be string");
        luaL_argcheck(L, lua_type(L, -1) == LUA_TTABLE, 2,
                "Type of changes list must be table");
        size_t base_len;
        const char* base = luaL_checklstring(L, -2, &base_len);
        luaL_argcheck(L, base_len == 1, 2,
                "Length of a base must be 1");
        char base_char = base[0];
        int nchanges = npge_rawlen(L, -1);
        for (int i = 1; i <= nchanges; i++) {
            lua_rawgeti(L, -1, i);
            int pos = luaL_checkinteger(L, -1);
            luaL_argcheck(L, pos >= 0, 2, "pos >= 0");
            luaL_argcheck(L, pos < length, 2, "pos < length");
            buffer[pos] = base_char;
            lua_pop(L, 1);
        }
        lua_pop(L, 1); // pop 'value'
    }
    lua_pushlstring(L, buffer, length);
    return 1;
}

// arguments:
// 1. Lua table with rows
// 2. (optional) min_identity
// 3. (optional) min_length
// returns array of integers: 0-100 (100 is good)
int lua_good_columns(lua_State *L) {
    const int DEFAULT_VALUE = -1;
    int min_identity = luaL_optinteger(L, 2, DEFAULT_VALUE);
    int min_length = luaL_optinteger(L, 3, DEFAULT_VALUE);
    //
    luaL_checktype(L, 1, LUA_TTABLE);
    int nrows = npge_rawlen(L, 1);
    if (nrows == 0) {
        lua_newtable(L);
        return 1;
    }
    int length;
    const char** rows = toRows(L, 1, nrows, length);
    if (length == 0) {
        lua_newtable(L);
        return 1;
    }
    Scores scores = goodColumns(rows, nrows, length,
            min_identity, min_length);
    // table of integers
    lua_createtable(L, length, 0);
    for (int i = 0; i < length; i++) {
        lua_pushinteger(L, scores[i]);
        lua_rawseti(L, -2, i + 1);
    }
    return 1;
}

// arguments:
// 1. scores, Lua table of integers
// 2. frame_length (integer)
// 3. end_length (integer)
// 4. min_identity (integer) 0-100
// 5. min_length (integer)
// returns array of slice. Each slice is {start, stop}.
int lua_goodSlices(lua_State *L) {
    luaL_checktype(L, 1, LUA_TTABLE);
    int block_length = npge_rawlen(L, 1);
    if (block_length == 0) {
        lua_newtable(L);
        return 1;
    }
    int frame_length = luaL_checkinteger(L, 2);
    int end_length = luaL_checkinteger(L, 3);
    int min_identity = luaL_checkinteger(L, 4);
    int min_length = luaL_checkinteger(L, 5);
    Scores scores(block_length);
    for (int i = 0; i < block_length; i++) {
        lua_rawgeti(L, 1, i + 1);
        // not luaL_checkinteger not to throw (vector scores)
        scores[i] = lua_tointeger(L, -1);
        lua_pop(L, 1);
    }
    Coordinates slices = goodSlices(scores,
            frame_length, end_length,
            min_identity, min_length);
    lua_createtable(L, slices.size(), 0); // slices
    for (int i = 0; i < slices.size(); i++) {
        const StartStop& slice = slices[i];
        lua_createtable(L, 2, 0); // {start, stop}
        lua_pushinteger(L, slice.first);
        lua_rawseti(L, -2, 1); // start
        lua_pushinteger(L, slice.second);
        lua_rawseti(L, -2, 2); // stop
        lua_rawseti(L, -2, i + 1); // result[i] = {start,stop}
    }
    return 1;
}

// arguments:
// 1. Lua table with rows
// results:
// 1. Lua table with alignment
// 2. Lua table with remaining parts of rows (tails)
static int lua_left(lua_State *L) {
    Aln aln;
    luaL_checktype(L, 1, LUA_TTABLE);
    aln.right_aligned = lua_toboolean(L, 2);
    aln.nrows = npge_rawlen(L, 1);
    if (aln.nrows == 0) {
        lua_newtable(L); // prefixes
        lua_newtable(L); // tails
        return 2;
    }
    aln.rows = toRows(L, 1, aln.nrows, aln.lens);
    size_t min_len;
    for (int irow = 0; irow < aln.nrows; irow++) {
        if (irow == 0 || aln.lens[irow] < min_len) {
            min_len = aln.lens[irow];
        }
    }
    // read config
    lua_getglobal(L, "require");
    lua_pushliteral(L, "npge.config");
    lua_call(L, 1, 1);
    lua_getfield(L, -1, "alignment");
    lua_getfield(L, -1, "MISMATCH_CHECK");
    aln.MISMATCH_CHECK = luaL_checkinteger(L, -1);
    lua_getfield(L, -2, "GAP_CHECK");
    aln.GAP_CHECK = luaL_checkinteger(L, -1);
    // make alignment
    aln.max_row_len = min_len * 2 + aln.GAP_CHECK * 2;
    int aligned_size = aln.max_row_len * aln.nrows;
    aln.aligned = newLuaArray<char>(L, aligned_size);
    aln.used_aln = newLuaArray<int>(L, aln.nrows);
    aln.used_row = newLuaArray<int>(L, aln.nrows);
    memset(aln.used_aln, 0, aln.nrows * sizeof(int));
    memset(aln.used_row, 0, aln.nrows * sizeof(int));
    // align
    alignLeft(&aln);
    // push results
    lua_createtable(L, aln.nrows, 0); // aligned
    lua_createtable(L, aln.nrows, 0); // tails
    for (int irow = 0; irow < aln.nrows; irow++) {
        lua_pushlstring(L, alignedRow(&aln, irow),
                aln.used_aln[irow]); // aligned
        lua_rawseti(L, -3, irow + 1);
        //
        int used = aln.used_row[irow];
        lua_pushlstring(L, aln.rows[irow] + used,
                aln.lens[irow] - used); // tail
        lua_rawseti(L, -2, irow + 1);
    }
    return 2;
}

// arguments:
// 1. Lua table with rows
// results:
// 1. Lua table with common prefixes of rows
// 2. Lua table with remaining parts of rows (tails)
static int lua_moveIdentical(lua_State *L) {
    luaL_checktype(L, 1, LUA_TTABLE);
    int nrows = npge_rawlen(L, 1);
    if (nrows == 0) {
        lua_newtable(L); // prefixes
        lua_newtable(L); // tails
        return 2;
    }
    int* lens;
    const char** rows = toRows(L, 1, nrows, lens);
    size_t min_len;
    for (int irow = 0; irow < nrows; irow++) {
        if (irow == 0 || lens[irow] < min_len) {
            min_len = lens[irow];
        }
    }
    // find common prefix
    int prefix_len = prefixLength(rows, nrows, min_len);
    // results
    lua_pushlstring(L, rows[0], prefix_len);
    lua_createtable(L, nrows, 0); // prefixes
    lua_createtable(L, nrows, 0); // tails
    for (int irow = 0; irow < nrows; irow++) {
        lua_pushvalue(L, -3); // prefix
        lua_rawseti(L, -3, irow + 1);
        lua_pushlstring(L, rows[irow] + prefix_len,
                lens[irow] - prefix_len); // tail
        lua_rawseti(L, -2, irow + 1);
    }
    return 2;
}

// return require("npge.config").alignment.ANCHOR
static int getAnchor(lua_State* L) {
    lua_getglobal(L, "require");
    lua_pushliteral(L, "npge.config");
    lua_call(L, 1, 1);
    lua_getfield(L, -1, "alignment");
    lua_getfield(L, -1, "ANCHOR");
    int ANCHOR = luaL_checkinteger(L, -1);
    return ANCHOR;
}

// return require("npge.config").alignment.GAP_CHECK
static int getGapCheck(lua_State* L) {
    lua_getglobal(L, "require");
    lua_pushliteral(L, "npge.config");
    lua_call(L, 1, 1);
    lua_getfield(L, -1, "alignment");
    lua_getfield(L, -1, "GAP_CHECK");
    int ANCHOR = luaL_checkinteger(L, -1);
    return ANCHOR;
}

// return require("npge.config").general.MIN_LENGTH
static int getMinLength(lua_State* L) {
    lua_getglobal(L, "require");
    lua_pushliteral(L, "npge.config");
    lua_call(L, 1, 1);
    lua_getfield(L, -1, "general");
    lua_getfield(L, -1, "MIN_LENGTH");
    int MIN_LENGTH = luaL_checkinteger(L, -1);
    return MIN_LENGTH;
}

// arguments:
// 1. Lua table with rows
// results: nil or
// 1. Lua table with prefixes
// 2. Lua table with anchor
// 3. Lua table with suffixes
static int lua_anchor(lua_State *L) {
    luaL_checktype(L, 1, LUA_TTABLE);
    int nrows = npge_rawlen(L, 1);
    if (nrows == 0) {
        lua_pushnil(L);
        return 1;
    }
    int* lens;
    const char** rows = toRows(L, 1, nrows, lens);
    int ANCHOR = getAnchor(L);
    int MIN_ANCHOR = getGapCheck(L);
    int MIN_LENGTH = getMinLength(L);
    // find anchor
    int* anchor = newLuaArray<int>(L, nrows);
    bool ok = findAnchor(anchor, nrows, rows, lens,
                         ANCHOR, MIN_LENGTH, MIN_ANCHOR);
    // results
    if (!ok) {
        lua_pushnil(L);
        return 1;
    }
    lua_pushlstring(L, rows[0] + anchor[0], ANCHOR);
    lua_createtable(L, nrows, 0); // prefixes
    lua_createtable(L, nrows, 0); // anchor
    lua_createtable(L, nrows, 0); // suffixes
    for (int irow = 0; irow < nrows; irow++) {
        lua_pushlstring(L, rows[irow], anchor[irow]); // prefix
        lua_rawseti(L, -4, irow + 1); // prefix
        lua_pushvalue(L, -4); // anchor
        lua_rawseti(L, -3, irow + 1); // anchor
        int suffix_len = anchor[irow] + ANCHOR;
        lua_pushlstring(L, rows[irow] + suffix_len,
                lens[irow] - suffix_len); // suffix
        lua_rawseti(L, -2, irow + 1);
    }
    return 3;
}

// arguments:
// 1. Lua table with rows
// results:
// 1. Lua table with rows
static int lua_refineAlignment(lua_State *L) {
    luaL_checktype(L, 1, LUA_TTABLE);
    int nrows = npge_rawlen(L, 1);
    int len;
    const char** rows = toRows(L, 1, nrows, len);
    Strings aligned(nrows);
    for (int i = 0; i < nrows; i++) {
        aligned[i].assign(rows[i], len);
    }
    if (nrows != 0 && len != 0) {
        // refine
        refineAlignment(aligned);
    }
    // write result
    lua_createtable(L, nrows, 0);
    for (int irow = 0; irow < nrows; irow++) {
        const std::string& row = aligned[irow];
        lua_pushlstring(L, row.c_str(), row.length());
        lua_rawseti(L, -2, irow + 1);
    }
    return 1;
}

///

// -1 is module "model"
static void registerType(lua_State *L,
                         const char* type_name,
                         const char* mt_name,
                         const char* cache_name,
                         lua_CFunction constructor,
                         const luaL_Reg* mt,
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
    npge_setfuncs(L, mt);
    lua_newtable(L); // mt.__index
    npge_setfuncs(L, methods);
    lua_setfield(L, -2, "__index");
    lua_pop(L, 1); // metatable of instance
    // constructor
    lua_pushcfunction(L, constructor);
    lua_setfield(L, -2, type_name);
}

static const luaL_Reg string_functions[] = {
    {"toAtgcn", lua_toAtgcn},
    {"toAtgcnAndGap", lua_toAtgcnAndGap},
    {"complement", lua_complement},
    {"unwindRow", lua_unwindRow},
    {"identity", lua_identity},
    {"consensus", lua_consensus},
    {"diff", lua_ShortForm_diff},
    {"patch", lua_ShortForm_patch},
    {"goodColumns", lua_good_columns},
    {"goodSlices", lua_goodSlices},
    {NULL, NULL}
};

static const luaL_Reg alignment_functions[] = {
    {"left", lua_left},
    {"moveIdentical", lua_moveIdentical},
    {"anchor", lua_anchor},
    {"refine", lua_refineAlignment},
    {NULL, NULL}
};

extern "C" {
int luaopen_npge_cpp(lua_State *L) {
    lua_newtable(L); // npge.cpp
    lua_newtable(L); // npge.cpp.model
    registerType(L, "Sequence", "npge_Sequence",
                 "npge_Sequence_cache", wrap<lua_Sequence>::func,
                 Sequence_mt, Sequence_methods);
    registerType(L, "Fragment", "npge_Fragment",
                 "npge_Fragment_cache", wrap<lua_Fragment>::func,
                 Fragment_mt, Fragment_methods);
    registerType(L, "Block", "npge_Block",
                 "npge_Block_cache", wrap<lua_Block>::func,
                 Block_mt, Block_methods);
    registerType(L, "BlockSet", "npge_BlockSet",
                 "npge_BlockSet_cache", wrap<lua_BlockSet>::func,
                 BlockSet_mt, BlockSet_methods);
    registerBlockSetFromRef(L);
    lua_setfield(L, -2, "model");
    //
    lua_newtable(L); // npge.cpp.block
    npge_setfuncs(L, block_functions);
    lua_setfield(L, -2, "block");
    //
    lua_newtable(L); // npge.cpp.func
    npge_setfuncs(L, string_functions);
    lua_setfield(L, -2, "func");
    //
    lua_newtable(L); // npge.cpp.alignment
    npge_setfuncs(L, alignment_functions);
    lua_pushinteger(L, MAX_COLUMN_SCORE);
    lua_setfield(L, -2, "MAX_COLUMN_SCORE");
    lua_setfield(L, -2, "alignment");
    return 1;
}

}
