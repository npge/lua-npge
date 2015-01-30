#include <stdlib.h>

#define LUA_LIB
#include <lua.h>
#include <lauxlib.h>

int prefixLength(const char** rows, int nrows, int len) {
    int icol;
    for (icol = 0; icol < len; icol++) {
        char first = rows[0][icol];
        int good = 1;
        int irow;
        for (irow = 1; irow < nrows; irow++) {
            if (rows[irow][icol] != first) {
                good = 0;
                return icol;
            }
        }
    }
    return len;
}

// arguments:
// 1. Lua table with rows
// results:
// 1. Lua table with common prefixes of rows
// 2. Lua table with remaining parts of rows (tails)
static int lua_move_identical(lua_State *L) {
    luaL_checktype(L, 1, LUA_TTABLE);
    int nrows = lua_objlen(L, 1);
    if (nrows == 0) {
        lua_newtable(L); // prefixes
        lua_newtable(L); // tails
        return 2;
    }
    const char** rows = malloc(nrows * sizeof(const char*));
    size_t* lens = malloc(nrows * sizeof(size_t));
    // populate rows
    int irow;
    size_t min_len;
    for (irow = 0; irow < nrows; irow++) {
        lua_rawgeti(L, 1, irow + 1);
        size_t len;
        const char* row = luaL_checklstring(L, -1, &len);
        rows[irow] = row;
        lens[irow] = len;
        if (irow == 0 || len < min_len) {
            min_len = len;
        }
        lua_pop(L, 1);
    }
    // find common prefix
    int prefix_len = prefixLength(rows, nrows, min_len);
    // results
    lua_pushlstring(L, rows[0], prefix_len);
    lua_createtable(L, nrows, 0); // prefixes
    lua_createtable(L, nrows, 0); // tails
    for (irow = 0; irow < nrows; irow++) {
        lua_pushvalue(L, -3); // prefix
        lua_rawseti(L, -3, irow + 1);
        lua_pushlstring(L, rows[irow] + prefix_len,
                lens[irow] - prefix_len); // tail
        lua_rawseti(L, -2, irow + 1);
    }
    free(rows);
    free(lens);
    return 2;
}

LUALIB_API int luaopen_npge_alignment_cmove_identical(
        lua_State *L) {
    lua_pushcfunction(L, lua_move_identical);
    return 1;
}
