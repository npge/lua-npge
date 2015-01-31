#include <stdlib.h>
#include <assert.h>

#define LUA_LIB
#include <lua.h>
#include <lauxlib.h>

// arguments:
// 1. Lua table with rows
// 2. number of rows
// 3. start position
// 4. stop position
static int lua_identity(lua_State *L) {
    luaL_checktype(L, 1, LUA_TTABLE);
    int nrows = luaL_checknumber(L, 2);
    int start = luaL_checknumber(L, 3);
    int stop = luaL_checknumber(L, 4);
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
        lua_pop(L, 1); // remove 'value'
        irow++;
    }
    assert(irow == nrows);
    // calculate identity
    int bp;
    double ident = 0;
    for (bp = start; bp <= stop; bp++) {
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
    double l = stop - start + 1;
    double result = ident / l;
    lua_pushnumber(L, result);
    lua_pushnumber(L, ident);
    lua_pushnumber(L, l);
    free(rows);
    return 3;
}

LUALIB_API int luaopen_npge_alignment_cidentity(lua_State *L) {
    lua_pushcfunction(L, lua_identity);
    return 1;
}
