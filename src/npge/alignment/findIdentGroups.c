#define LUA_LIB
#include <lua.h>
#include <lauxlib.h>

// Lua version in file block/good_subblocks.lua

static int identCol(int nrows, const char** rows, int bp) {
    char first = rows[0][bp];
    if (first == '-') {
        return 0;
    }
    int irow;
    for (irow = 1; irow < nrows; irow++) {
        char c = rows[irow][bp];
        if (c != first || c == '-') {
            return 0;
        }
    }
    return 1;
}

static void createGroup(lua_State* L, int start, int stop) {
    lua_createtable(L, 0, 2);
    lua_pushnumber(L, start);
    lua_setfield(L, -2, "start");
    lua_pushnumber(L, stop);
    lua_setfield(L, -2, "stop");
}

// arguments:
// 1. Lua table with rows
// 2. minimum number of columns in group
static int lua_findIdentGroups(lua_State *L) {
    luaL_checktype(L, 1, LUA_TTABLE);
    int nrows = lua_objlen(L, 1);
    if (nrows == 0) {
        lua_pushnil(L);
        return 1;
    }
    int min_cols = luaL_checknumber(L, 2);
    // populate rows
    const char** rows = lua_newuserdata(L,
            nrows * sizeof(const char*));
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
    // create table for groups
    lua_newtable(L);
    int group_index = 1;
    // find identical groups
    int bp;
    int start = -1;
    int stop = -1;
    for (bp = 0; bp < length; bp++) {
        if (identCol(nrows, rows, bp)) {
            if (stop != -1) {
                stop = bp;
            } else {
                start = bp;
                stop = bp;
            }
        } else if (start != -1) {
            int length = stop - start + 1;
            if (length >= min_cols) {
                // create ident group
                createGroup(L, start, stop);
                lua_rawseti(L, -2, group_index);
                group_index += 1;
            }
            start = -1;
            stop = -1;
        }
    }
    if (start != -1) {
        int length = stop - start + 1;
        if (length >= min_cols) {
            createGroup(L, start, stop);
            lua_rawseti(L, -2, group_index);
            group_index += 1;
        }
    }
    return 1;
}

LUALIB_API int luaopen_npge_alignment_cfindIdentGroups(
        lua_State *L) {
    lua_pushcfunction(L, lua_findIdentGroups);
    return 1;
}
