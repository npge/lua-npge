#include <string.h>
#include <assert.h>

#define LUA_LIB
#include <lua.h>
#include <lauxlib.h>

static int getAnchor(lua_State* L) {
    lua_getglobal(L, "require");
    lua_pushliteral(L, "npge.config");
    lua_call(L, 1, 1);
    lua_getfield(L, -1, "alignment");
    lua_getfield(L, -1, "ANCHOR");
    int ANCHOR = luaL_checkint(L, -1);
    return ANCHOR;
}

static int getMinLength(lua_State* L) {
    lua_getglobal(L, "require");
    lua_pushliteral(L, "npge.config");
    lua_call(L, 1, 1);
    lua_getfield(L, -1, "general");
    lua_getfield(L, -1, "MIN_LENGTH");
    int MIN_LENGTH = luaL_checkint(L, -1);
    return MIN_LENGTH;
}

static int maxLength(int nrows, int* lens) {
    int max_len;
    int irow;
    for (irow = 0; irow < nrows; irow++) {
        int len = lens[irow];
        if (irow == 0 || len > max_len) {
            max_len = len;
        }
    }
    return max_len;
}

const int POSSIBLE_LETTERS = 5;

// 5^13 fits in int, 5^14 is not
const int MAX_NUMBER_ANCHOR = 13;

static const unsigned char LETTER_TO_NUMBER[] = {
0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
0, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 4, 0,
0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
};

int wordToNumber(const char* word, int len) {
    int value = 0;
    int i;
    for (i = 0; i < len; i++) {
        unsigned char c = word[i];
        value *= POSSIBLE_LETTERS;
        value += LETTER_TO_NUMBER[c];
    }
    return value;
}

// userdata pos is int[nrows + 1].
// first nrows elements are positions of anchor in
// rows from 0 to nrows-1 (by default -1).
// last element is number of found words (by default 0).
static int* newPos(lua_State* L, int nrows) {
    int pos_size = sizeof(int) * (nrows + 1);
    int* pos = lua_newuserdata(L, pos_size);
    int irow;
    for (irow = 0; irow < nrows; irow++) {
        pos[irow] = -1;
    }
    pos[nrows] = 0;
    return pos;
}

static int* getByNumberKey(lua_State* L, int nrows,
        const char* word, int ANCHOR) {
    int* pos;
    int n = wordToNumber(word, ANCHOR);
    lua_rawgeti(L, -1, n);
    if (lua_type(L, -1) == LUA_TNIL) {
        lua_pop(L, 1); // remove nil
        pos = newPos(L, nrows);
        lua_rawseti(L, -2, n);
    } else {
        pos = lua_touserdata(L, -1);
        lua_pop(L, 1); // remove pos
    }
    return pos;
}

static int* getByStringKey(lua_State* L, int nrows,
        const char* word, int ANCHOR) {
    int* pos;
    lua_pushlstring(L, word, ANCHOR);
    lua_rawget(L, -2);
    if (lua_type(L, -1) == LUA_TNIL) {
        lua_pop(L, 1); // remove nil
        lua_pushlstring(L, word, ANCHOR);
        pos = newPos(L, nrows);
        lua_rawset(L, -3);
    } else {
        pos = lua_touserdata(L, -1);
        lua_pop(L, 1); // remove pos
    }
    return pos;
}

// compare all rows. If all are equal, returns 1
int compareWords(lua_State* L, int nrows,
        const char** rows, int* lens, int ANCHOR, int start) {
    if (start + ANCHOR > lens[0]) {
        return 0;
    }
    const char* first = rows[0] + start;
    int irow;
    for (irow = 1; irow < nrows; irow++) {
        int len = lens[irow];
        if (start + ANCHOR > len) {
            return 0;
        }
        const char* word = rows[irow] + start;
        if (memcmp(first, word, ANCHOR) != 0) {
            return 0;
        }
    }
    return 1;
}

static int* makeFilledPos(lua_State* L, int nrows, int start) {
    // locate result in Lua table
    int* pos = newPos(L, nrows);
    int some_index = 0;
    lua_rawseti(L, -2, 0);
    int irow;
    for (irow = 0; irow < nrows; irow++) {
        pos[irow] = start;
    }
    pos[nrows] = nrows; // number of found words
    return pos;
}

// table (word => int[nrows]) is on top of stack
int* addWords(lua_State* L, int nrows, const char** rows,
        int* lens, int ANCHOR, int start) {
    // compare all rows. If all are equal, returns this
    int all_equal = compareWords(L, nrows, rows, lens,
            ANCHOR, start);
    if (all_equal) {
        return makeFilledPos(L, nrows, start);
    }
    // compare to known words
    int irow;
    for (irow = 0; irow < nrows; irow++) {
        int len = lens[irow];
        if (start + ANCHOR <= len) {
            const char* word = rows[irow] + start;
            int* pos = 0;
            if (ANCHOR <= MAX_NUMBER_ANCHOR) {
                pos = getByNumberKey(L, nrows, word, ANCHOR);
            } else {
                pos = getByStringKey(L, nrows, word, ANCHOR);
            }
            assert(pos);
            if (pos[irow] == -1) {
                pos[irow] = start;
                pos[nrows] += 1;
                if (pos[nrows] == nrows) {
                    return pos;
                }
            }
        }
    }
    return 0;
}

// returns list of anchor starts or 0
// Lua state is used for hash table
static int* findAnchor(lua_State* L, int nrows,
        const char** rows, int* lens) {
    int ANCHOR = getAnchor(L);
    int MIN_LENGTH = getMinLength(L);
    int max_len = maxLength(nrows, lens);
    int last = max_len - ANCHOR;
    if (last > MIN_LENGTH) {
        last = MIN_LENGTH;
    }
    lua_newtable(L); // hash table: word => int[nrows]
    int start;
    for (start = 0; start <= last; start++) {
        int* anchor = addWords(L, nrows, rows,
                lens, ANCHOR, start);
        if (anchor) {
            return anchor;
        }
    }
    return 0;
}

// arguments:
// 1. Lua table with rows
// results: nil or
// 1. Lua table with prefixes
// 2. Lua table with anchor
// 3. Lua table with suffixes
static int lua_anchor(lua_State *L) {
    luaL_checktype(L, 1, LUA_TTABLE);
    int nrows = lua_objlen(L, 1);
    if (nrows == 0) {
        lua_pushnil(L);
        return 1;
    }
    const char** rows = lua_newuserdata(L,
            nrows * sizeof(const char*));
    int* lens = lua_newuserdata(L, nrows * sizeof(int));
    // populate rows
    int irow;
    for (irow = 0; irow < nrows; irow++) {
        lua_rawgeti(L, 1, irow + 1);
        size_t len;
        const char* row = luaL_checklstring(L, -1, &len);
        rows[irow] = row;
        lens[irow] = len;
        lua_pop(L, 1);
    }
    // get ANCHOR
    int ANCHOR = getAnchor(L);
    // find anchor
    int* anchor = findAnchor(L, nrows, rows, lens);
    // results
    if (!anchor) {
        lua_pushnil(L);
        return 1;
    }
    lua_pushlstring(L, rows[0] + anchor[0], ANCHOR);
    lua_createtable(L, nrows, 0); // prefixes
    lua_createtable(L, nrows, 0); // anchor
    lua_createtable(L, nrows, 0); // suffixes
    for (irow = 0; irow < nrows; irow++) {
        lua_pushlstring(L, rows[irow], anchor[irow]); // prefix
        lua_rawseti(L, -4, irow + 1); // prefix
        lua_pushvalue(L, -4); // anchor
        lua_rawseti(L, -3, irow + 1); // anchor
        int suffix_len = anchor[irow] + ANCHOR;
        lua_pushlstring(L, rows[irow] + suffix_len,
                lens[irow] - suffix_len); // suffix
        lua_rawseti(L, -2, irow + 1);
    }
    // anchor is part of Lua state (uservalue in table)
    return 3;
}

int luaopen_npge_alignment_canchor(lua_State *L) {
    lua_pushcfunction(L, lua_anchor);
    return 1;
}
