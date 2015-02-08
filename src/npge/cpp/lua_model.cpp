/*
 * NPG-explorer, Nucleotide PanGenome explorer
 * Copyright (C) 2012-2015 Boris Nagaev
 *
 * See the LICENSE file for terms of use.
 */

#include <cstdlib>
#include <cassert>
#include <memory>

#define LUA_LIB
#include <lua.hpp>

#include "model.hpp"
#include "throw_assert.hpp"

using namespace npge;

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
    // check in cache
    // http://lua-users.org/lists/lua-l/2007-01/msg00128.html
    P* p = t.get();
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

static FragmentPtr& lua_tofragment(lua_State* L, int index) {
    return fromLua<FragmentPtr>(L, index, "npge_Fragment");
}

static void lua_pushfr(lua_State* L, const FragmentPtr& fr) {
    toLua<FragmentPtr, Fragment>(L, fr,
            "npge_Fragment", "npge_Fragment_cache");
}

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
    FragmentPtr& fragment = lua_tofragment(L, 1);
    fragment.reset();
    return 0;
}

int lua_Fragment_type(lua_State *L) {
    lua_pushstring(L, "Fragment");
    return 1;
}

int lua_Fragment_sequence(lua_State *L) {
    const FragmentPtr& fragment = lua_tofragment(L, 1);
    lua_pushseq(L, fragment->sequence());
    return 1;
}

int lua_Fragment_start(lua_State *L) {
    const FragmentPtr& fragment = lua_tofragment(L, 1);
    lua_pushinteger(L, fragment->start());
    return 1;
}

int lua_Fragment_stop(lua_State *L) {
    const FragmentPtr& fragment = lua_tofragment(L, 1);
    lua_pushinteger(L, fragment->stop());
    return 1;
}

int lua_Fragment_ori(lua_State *L) {
    const FragmentPtr& fragment = lua_tofragment(L, 1);
    lua_pushinteger(L, fragment->ori());
    return 1;
}

int lua_Fragment_parted(lua_State *L) {
    const FragmentPtr& fragment = lua_tofragment(L, 1);
    lua_pushboolean(L, fragment->parted());
    return 1;
}

int lua_Fragment_length(lua_State *L) {
    const FragmentPtr& fragment = lua_tofragment(L, 1);
    lua_pushinteger(L, fragment->length());
    return 1;
}

int lua_Fragment_id(lua_State *L) {
    const FragmentPtr& fragment = lua_tofragment(L, 1);
    std::string id = fragment->id();
    lua_pushlstring(L, id.c_str(), id.length());
    return 1;
}

int lua_Fragment_parts_impl(lua_State *L) {
    const FragmentPtr& fragment = lua_tofragment(L, 1);
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
    const FragmentPtr& fragment = lua_tofragment(L, 1);
    std::string text = fragment->text();
    lua_pushlstring(L, text.c_str(), text.length());
    return 1;
}

int lua_Fragment_tostring(lua_State *L) {
    const FragmentPtr& fragment = lua_tofragment(L, 1);
    std::string repr = fragment->tostring();
    lua_pushlstring(L, repr.c_str(), repr.size());
    return 1;
}

int lua_Fragment_common(lua_State *L) {
    const FragmentPtr& a = lua_tofragment(L, 1);
    const FragmentPtr& b = lua_tofragment(L, 2);
    lua_pushinteger(L, a->common(*b));
    return 1;
}

int lua_Fragment_eq(lua_State *L) {
    const FragmentPtr& a = lua_tofragment(L, 1);
    const FragmentPtr& b = lua_tofragment(L, 2);
    lua_pushboolean(L, (*a) == (*b));
    return 1;
}

int lua_Fragment_lt_impl(lua_State *L) {
    const FragmentPtr& a = lua_tofragment(L, 1);
    const FragmentPtr& b = lua_tofragment(L, 2);
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

extern "C" {
int luaopen_npge_cmodel(lua_State *L) {
    lua_newtable(L);
    registerType(L, "Sequence", "npge_Sequence",
                 "npge_Sequence_cache",
                 lua_Sequence, Sequence_methods);
    registerType(L, "Fragment", "npge_Fragment",
                 "npge_Fragment_cache",
                 lua_Fragment, Fragment_methods);
    return 1;
}

}
