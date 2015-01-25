#include <stdlib.h>
#include <string.h>
#include <assert.h>

#define LUA_LIB
#include <lua.h>
#include <lauxlib.h>

typedef struct {
    char* text_;
    int len_;
} SequenceText;


// closure, first upvalue is metatable of instance
// arguments:
// 1. SequenceText_mt (dummy)
// 2. string text
// returns userdata SequenceText
static int lua_SequenceText_constructor(lua_State *L) {
    int args = lua_gettop(L);
    assert(args == 2);
    size_t len;
    const char* text = lua_tolstring(L, 2, &len);
    assert(len > 0);
    SequenceText* t = lua_newuserdata(L, sizeof(SequenceText));
    t->text_ = malloc(len);
    memcpy(t->text_, text, len);
    t->len_ = len;
    // get metatable of SequenceText
    lua_pushvalue(L, lua_upvalueindex(1));
    lua_setmetatable(L, -2);
    return 1;
}

static int lua_SequenceText_free(lua_State *L) {
    SequenceText* text = lua_touserdata(L, 1);
    free(text->text_);
    return 0;
}

static int SequenceText_eq(SequenceText* self,
                           SequenceText* other) {
    if (self->len_ != other->len_) {
        return 0;
    }
    if (memcmp(self->text_, other->text_, other->len_) != 0) {
        return 0;
    }
    return 1;
}

static int lua_SequenceText_eq(lua_State *L) {
    SequenceText* self = lua_touserdata(L, 1);
    SequenceText* other = lua_touserdata(L, 2);
    lua_pushboolean(L, SequenceText_eq(self, other));
    return 1;
}

// arguments:
// 1. SequenceText self
// returns length
static int lua_SequenceText_length(lua_State *L) {
    int args = lua_gettop(L);
    assert(args == 1);
    SequenceText* t = lua_touserdata(L, 1);
    assert(t);
    lua_pushnumber(L, t->len_);
    return 1;
}

// arguments:
// 1. SequenceText self
// 2. min
// 3. max
// returns slice (string)
static int lua_SequenceText_sub(lua_State *L) {
    int args = lua_gettop(L);
    assert(args == 3);
    SequenceText* t = lua_touserdata(L, 1);
    int min = lua_tonumber(L, 2);
    int max = lua_tonumber(L, 3);
    assert(min >= 0);
    assert(min <= max);
    assert(max < t->len_);
    char* text = t->text_;
    char* start = text + min;
    int length = max - min + 1;
    assert(length > 0);
    lua_pushlstring(L, start, length);
    return 1;
}

static const luaL_Reg seqtextlib[] = {
    {"__gc", lua_SequenceText_free},
    {"__eq", lua_SequenceText_eq},
    {"length", lua_SequenceText_length},
    {"sub", lua_SequenceText_sub},
    {NULL, NULL}
};

LUALIB_API int luaopen_npge_model_cSequenceText(lua_State *L) {
    // instance mt
    lua_newtable(L);
    luaL_register(L, NULL, seqtextlib);
    lua_pushvalue(L, -1);
    lua_setfield(L, -2, "__index"); // mt.__index = mt
    // constructor
    lua_pushcclosure(L, lua_SequenceText_constructor, 1);
    // SequenceText_mt
    lua_newtable(L);
    lua_pushvalue(L, -2); // constructor
    // SequenceText_mt.__call = constructor
    lua_setfield(L, -2, "__call");
    // module SequenceText
    lua_newtable(L);
    lua_pushvalue(L, -2); // SequenceText_mt
    lua_setmetatable(L, -2);
    return 1; // module SequenceText
}
