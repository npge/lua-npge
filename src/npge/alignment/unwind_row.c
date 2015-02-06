#include <stdlib.h>

#define LUA_LIB
#include <lua.h>
#include <lauxlib.h>

// arguments:
// 1. row
// 2. orig
static int lua_unwind_row(lua_State *L) {
    size_t row_size, orig_size;
    const char* row = luaL_checklstring(L, 1, &row_size);
    const char* orig = luaL_checklstring(L, 2, &orig_size);
    luaL_argcheck(L, row_size >= orig_size, 1,
            "Length of row on consensus must be >= "
            "length of row on original sequence");
    char* result = malloc(row_size);
    int orig_i = 0;
    int i;
    for (i = 0; i < row_size; i++) {
        char c = row[i];
        if (c == '-') {
            result[i] = '-';
        } else {
            luaL_argcheck(L, orig_i < orig_size, 2,
                "Length of original row is not sufficient");
            result[i] = orig[orig_i];
            orig_i += 1;
        }
    }
    luaL_argcheck(L, orig_i == orig_size, 2,
        "Original row is too long");
    lua_pushlstring(L, result, row_size);
    free(result);
    return 1;
}

int luaopen_npge_alignment_cunwind_row(
        lua_State *L) {
    lua_pushcfunction(L, lua_unwind_row);
    return 1;
}
