#include <stdlib.h>
#include <string.h>
#include <assert.h>

#define LUA_LIB
#include <lua.h>
#include <lauxlib.h>

typedef struct {
    int sequence_;
    int start_;
    int stop_;
    int ori_;
} Fragment;

// closure, first upvalue is metatable of Fragment instance
// arguments:
// 1. Sequence
// 2. start
// 3. stop
// 4. ori
static int lua_Fragment_constructor(lua_State *L) {
    int args = lua_gettop(L);
    assert(args == 4);
    Fragment* f = lua_newuserdata(L, sizeof(Fragment));
    lua_pushvalue(L, 1); // sequence
    f->sequence_ = luaL_ref(L, LUA_REGISTRYINDEX);
    f->start_ = lua_tonumber(L, 2);
    f->stop_ = lua_tonumber(L, 3);
    f->ori_ = lua_tonumber(L, 4);
    // get metatable of Fragment
    lua_pushvalue(L, lua_upvalueindex(1));
    lua_setmetatable(L, -2);
    return 1; // Fragment instance
}

static int lua_Fragment_free(lua_State *L) {
    Fragment* f = lua_touserdata(L, 1);
    luaL_unref(L, LUA_REGISTRYINDEX, f->sequence_);
    return 0;
}

static int lua_Fragment_sequence(lua_State *L) {
    Fragment* f = lua_touserdata(L, 1);
    lua_rawgeti(L, LUA_REGISTRYINDEX, f->sequence_);
    return 1;
}

static int lua_Fragment_start(lua_State *L) {
    Fragment* f = lua_touserdata(L, 1);
    lua_pushnumber(L, f->start_);
    return 1;
}

static int lua_Fragment_stop(lua_State *L) {
    Fragment* f = lua_touserdata(L, 1);
    lua_pushnumber(L, f->stop_);
    return 1;
}

static int lua_Fragment_ori(lua_State *L) {
    Fragment* f = lua_touserdata(L, 1);
    lua_pushnumber(L, f->ori_);
    return 1;
}

static int Fragment_parted(Fragment* f) {
    int diff = f->stop_ - f->start_;
    return (diff * f->ori_ < 0);
}

static int lua_Fragment_parted(lua_State *L) {
    Fragment* f = lua_touserdata(L, 1);
    lua_pushboolean(L, Fragment_parted(f));
    return 1;
}

static int lua_Fragment_length(lua_State *L) {
    Fragment* f = lua_touserdata(L, 1);
    int absdiff = abs(f->stop_ - f->start_);
    int length;
    if (!Fragment_parted(f)) {
        length = absdiff + 1;
    } else {
        lua_rawgeti(L, LUA_REGISTRYINDEX, f->sequence_);
        luaL_callmeta(L, -1, "length");
        int seq_length = lua_tonumber(L, -1);
        length = seq_length - absdiff + 1;
    }
    lua_pushnumber(L, length);
    return 1;
}

static int mymin(int a, int b) {
    if (a < b) {
        return a;
    } else {
        return b;
    }
}

static int mymax(int a, int b) {
    if (a > b) {
        return a;
    } else {
        return b;
    }
}

static int lua_Fragment_simple_common(lua_State *L) {
    Fragment* self = lua_touserdata(L, 1);
    Fragment* other = lua_touserdata(L, 2);
    int self_min = mymin(self->start_, self->stop_);
    int self_max = mymax(self->start_, self->stop_);
    int other_min = mymin(other->start_, other->stop_);
    int other_max = mymax(other->start_, other->stop_);
    int common_min = mymax(self_min, other_min);
    int common_max = mymin(self_max, other_max);
    int common = common_max - common_min + 1;
    if (common < 0) {
        common = 0;
    }
    lua_pushnumber(L, common);
    return 1;
}

// argument: Fragment
// output: Sequence name
static int lua_Sequence_name(lua_State *L) {
    Fragment* f = lua_touserdata(L, 1);
    lua_rawgeti(L, LUA_REGISTRYINDEX, f->sequence_);
    luaL_callmeta(L, -1, "name");
    return 1;
}

static int lua_Fragment_eq(lua_State *L) {
    Fragment* a = lua_touserdata(L, 1);
    Fragment* b = lua_touserdata(L, 2);
    int equal = a->start_ == b->start_ &&
        a->stop_ == b->stop_ &&
        a->ori_ == b->ori_;
    if (equal) {
        lua_pushcfunction(L, lua_Sequence_name);
        lua_pushvalue(L, 1);
        lua_call(L, 1, 1);
        size_t a_size;
        const char* a_name = lua_tolstring(L, -1, &a_size);
        //
        lua_pushcfunction(L, lua_Sequence_name);
        lua_pushvalue(L, 2);
        lua_call(L, 1, 1);
        size_t b_size;
        const char* b_name = lua_tolstring(L, -1, &b_size);
        if (a_size != b_size ||
                memcmp(a_name, b_name, a_size) != 0) {
            equal = 0;
        }
    }
    lua_pushboolean(L, equal);
    return 1;
}

static int Fragment_min(Fragment* f) {
    return mymin(f->start_, f->stop_);
}

static int Fragment_max(Fragment* f) {
    return mymax(f->start_, f->stop_);
}

static int Fragment_lt(lua_State* L) {
    Fragment* a = lua_touserdata(L, 1);
    Fragment* b = lua_touserdata(L, 2);
    luaL_argcheck(L, !Fragment_parted(a), 1,
            "Fragment compared must not be parted");
    luaL_argcheck(L, !Fragment_parted(b), 2,
            "Fragment compared must not be parted");
    //
    int a_min = Fragment_min(a);
    int b_min = Fragment_min(b);
    if (a_min < b_min) {
        return 1;
    }
    if (a_min > b_min) {
        return 0;
    }
    //
    int a_max = Fragment_max(a);
    int b_max = Fragment_max(b);
    if (a_max < b_max) {
        return 1;
    }
    if (a_max > b_max) {
        return 0;
    }
    //
    if (a->ori_ < b->ori_) {
        return 1;
    }
    if (a->ori_ > b->ori_) {
        return 0;
    }
    //
    lua_pushcfunction(L, lua_Sequence_name);
    lua_pushvalue(L, 1);
    lua_call(L, 1, 1);
    size_t a_size;
    const char* a_name = lua_tolstring(L, -1, &a_size);
    //
    lua_pushcfunction(L, lua_Sequence_name);
    lua_pushvalue(L, 2);
    lua_call(L, 1, 1);
    size_t b_size;
    const char* b_name = lua_tolstring(L, -1, &b_size);
    //
    if (strcmp(a_name, b_name) < 0) {
        return 1;
    }
    return 0;
}

static int lua_Fragment_lt(lua_State *L) {
    int result = Fragment_lt(L);
    lua_pushboolean(L, result);
    return 1;
}

static const luaL_Reg fragmentlib[] = {
    {"__gc", lua_Fragment_free},
    {"sequence", lua_Fragment_sequence},
    {"start", lua_Fragment_start},
    {"stop", lua_Fragment_stop},
    {"ori", lua_Fragment_ori},
    {"parted", lua_Fragment_parted},
    {"length", lua_Fragment_length},
    {"_simple_common", lua_Fragment_simple_common},
    {"__eq", lua_Fragment_eq},
    {"__lt", lua_Fragment_lt},
    {NULL, NULL}
};

// returns Fragment's metatable
// Fragment's constructor is assigned to key "constructor"
// and should be removed from the table on Lua side
// Lua must do the following as well: mt.__index = mt
LUALIB_API int luaopen_npge_model_cFragment(lua_State *L) {
    lua_newtable(L); // fragment_mt
    luaL_register(L, NULL, fragmentlib);
    lua_pushvalue(L, -1); // fragment_mt
    // constructor
    lua_pushcclosure(L, lua_Fragment_constructor, 1);
    lua_setfield(L, -2, "constructor");
    return 1;
}
