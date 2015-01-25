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

static const luaL_Reg fragmentlib[] = {
    {"__gc", lua_Fragment_free},
    {"sequence", lua_Fragment_sequence},
    {"start", lua_Fragment_start},
    {"stop", lua_Fragment_stop},
    {"ori", lua_Fragment_ori},
    {"__eq", lua_Fragment_eq},
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
