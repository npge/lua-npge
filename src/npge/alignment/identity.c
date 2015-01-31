#include <stdlib.h>

#define LUA_LIB
#include <lua.h>
#include <lauxlib.h>

// arguments:
// 1. Lua table with rows
// 2. start position
// 3. stop position
static int lua_identity(lua_State *L) {
    luaL_checktype(L, 1, LUA_TTABLE);
    int nrows = lua_objlen(L, 1);
    if (nrows == 0) {
        lua_pushnil(L);
        return 1;
    }
    // populate rows
    const char** rows = malloc(nrows * sizeof(const char*));
    int length;
    int irow;
    for (irow = 0; irow < nrows; irow++) {
        lua_rawgeti(L, 1, irow + 1);
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
    if (length == 0) {
        lua_pushnumber(L, 0);
        lua_pushnumber(L, 0);
        lua_pushnumber(L, 0);
        return 3;
    }
    // start and stop
    int start = 0;
    int stop = length - 1;
    if (lua_gettop(L) >= 2) {
        start = luaL_checknumber(L, 2);
        luaL_argcheck(L, start >= 0, 2, "start >= 0");
    }
    if (lua_gettop(L) >= 3) {
        stop = luaL_checknumber(L, 3);
        luaL_argcheck(L, start <= stop, 3, "start <= stop");
        luaL_argcheck(L, stop <= length - 1, 3,
                "stop <= length - 1");
    }
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
