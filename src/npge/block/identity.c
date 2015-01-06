#include <stdlib.h>
#include <assert.h>

#define LUA_LIB
#include <lua.h>

// arguments:
// 1. Lua table with rows
// 2. number of rows
// 3. length of a row
static int lua_identity(lua_State *L) {
    int args = lua_gettop(L);
    assert(args == 3);
    assert(lua_istable(L, 1));
    assert(lua_isnumber(L, 2));
    assert(lua_isnumber(L, 3));
    int nrows = lua_tonumber(L, 2);
    int row_length = lua_tonumber(L, 3);
    const char** rows = malloc(nrows * sizeof(const char*));
    // populate rows
    int irow = 0;
    int t = 1; // index of table
    lua_pushnil(L);  /* first key */
    while (lua_next(L, t) != 0) {
        // 'key' at index -2, 'value' at index -1
        assert(irow < nrows);
        size_t len;
        rows[irow] = lua_tolstring(L, -1, &len);
        assert(rows[irow]);
        assert(len == row_length);
        lua_pop(L, 1); // remove 'value'
        irow++;
    }
    assert(irow == nrows);
    // calculate identity
    int bp;
    double ident = 0;
    for (bp = 0; bp < row_length; bp++) {
        int gap = 0;
        char first = 0;
        int bad = 0;
        for (irow = 0; irow < nrows; irow++) {
            char letter = rows[irow][bp];
            if (letter == '-') {
                gap = 1;
            } else if (first && letter != first) {
                bad = 1;
                break;
            } else {
                first = letter;
            }
        }
        if (!bad && !gap) {
            ident += 1;
        } else if (!bad && gap) {
            ident += 0.5;
        }
    }
    double result = ident / ((double)row_length);
    lua_pushnumber(L, result);
    free(rows);
    return 1;
}

LUALIB_API int luaopen_npge_block_cidentity(lua_State *L) {
    lua_pushcfunction(L, lua_identity);
    return 1;
}
