#include <stdlib.h>

#define LUA_LIB
#include <lua.h>
#include <lauxlib.h>

static const unsigned char ATGCN_GAP_MAP[] = {
0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
0, 0, 0, 0, 0, '-', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
0, 0, 0, 0, 0, 0, 'A', 'N', 'C', 'N', 0, 0, 'G', 'N', 0, 0,
'N', 0, 'N', 'N', 0, 0, 0, 'N', 'N', 'T', 0, 'N', 'N', 0,
'N', 0, 0, 0, 0, 0, 0, 0, 'A', 'N', 'C', 'N', 0, 0, 'G',
'N', 0, 0, 'N', 0, 'N', 'N', 0, 0, 0, 'N', 'N', 'T', 0,
'N', 'N', 0, 'N', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
};

// arguments:
// 1. text
static int lua_to_atgcn_and_gap(lua_State *L) {
    size_t text_size;
    const char* text = luaL_checklstring(L, 1, &text_size);
    if (text_size == 0) {
        lua_pushlstring(L, text, text_size);
        return 1;
    }
    char* result = malloc(text_size);
    int result_i = 0;
    int i;
    for (i = 0; i < text_size; i++) {
        unsigned char c = text[i];
        char c1 = ATGCN_GAP_MAP[c];
        if (c1) {
            result[result_i] = c1;
            result_i += 1;
        }
    }
    lua_pushlstring(L, result, result_i);
    free(result);
    return 1;
}

LUALIB_API int luaopen_npge_alignment_cto_atgcn_and_gap(
        lua_State *L) {
    lua_pushcfunction(L, lua_to_atgcn_and_gap);
    return 1;
}
