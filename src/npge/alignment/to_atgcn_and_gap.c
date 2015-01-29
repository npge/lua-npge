#include <stdlib.h>
#include <ctype.h>

#define LUA_LIB
#include <lua.h>
#include <lauxlib.h>

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
        char c = toupper(text[i]);
        if (c == 'R' || c == 'Y' || c == 'M' ||
                c == 'K' || c == 'W' || c == 'S' ||
                c == 'B' || c == 'V' || c == 'H' ||
                c == 'D') {
            result[result_i] = 'N';
            result_i += 1;
        } else if (c == 'A' || c == 'T' || c == 'G' ||
                c == 'C' || c == 'N' || c == '-') {
            result[result_i] = c;
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
