#include <stdlib.h>
#include <assert.h>

#define LUA_LIB
#include <lua.h>
#include <lauxlib.h>

typedef struct {
    // ptr points to int[2*len] (starts + lengths)
    int* ptr_;
    int len_;
} Row;

static int* Row_starts(Row* self) {
    return self->ptr_;
}

static int* Row_lengths(Row* self) {
    return self->ptr_ + self->len_;
}

static void Row_constructor(Row* self, const char* text,
                            int row_length) {
    assert(row_length > 0);
    // count groups
    int groups = 0;
    char prev = '-';
    int bp;
    for (bp = 0; bp < row_length; bp++) {
        if (prev == '-' && text[bp] != '-') {
            groups += 1;
        }
        prev = text[bp];
    }
    groups += 1; // last pseudo-group stores lengths
    // * 2 because two arrays in one (starts + lengths)
    self->ptr_ = malloc(sizeof(int) * groups * 2);
    self->len_ = groups;
    int* starts = Row_starts(self);
    int* lengths = Row_lengths(self);
    // fill starts and lengths
    prev = '-';
    int group = 0;
    lengths[0] = 0;
    for (bp = 0; bp < row_length; bp++) {
        if (prev == '-' && text[bp] != '-') {
            // new nongap opened
            starts[group] = bp;
            lengths[group + 1] = lengths[group] + 1;
            group += 1;
        } else if (text[bp] != '-') {
            // increase length of last group of nongaps
            lengths[group] += 1;
        }
        prev = text[bp];
    }
    starts[group] = row_length;
}

// closure, first upvalue is metatable of Row instance
static int lua_Row_constructor(lua_State *L) {
    int args = lua_gettop(L);
    if (args != 2) {
        return luaL_error(L,
                "Row's constructor must be called "
                "with one argument (text of row)");
    }
    if (!lua_isstring(L, 2)) {
        return luaL_error(L,
                "Row's constructor must be called "
                 "with a string");
    }
    size_t len;
    const char* text = lua_tolstring(L, 2, &len);
    if (len == 0) {
        return luaL_error(L, "Row('') called");
    }
    Row* row = lua_newuserdata(L, sizeof(Row));
    Row_constructor(row, text, len);
    // get metatable of Row
    lua_pushvalue(L, lua_upvalueindex(1));
    lua_setmetatable(L, -2);
    return 1; // Row instance
}

static void Row_free(Row* self) {
    free(self->ptr_);
}

static int lua_Row_free(lua_State *L) {
    Row* row = lua_touserdata(L, 1);
    Row_free(row);
    return 0;
}

// bool
static int arrays_equal(int len, int* x, int* y) {
    int i;
    for (i = 0; i < len; i++) {
        if (x[i] != y[i]) {
            return 0;
        }
    }
    return 1;
}

// bool
static int Row_eq(Row* x, Row* y) {
    int len = x->len_;
    return x->len_ == y->len_ &&
        arrays_equal(len, Row_starts(x), Row_starts(y)) &&
        arrays_equal(len, Row_lengths(x), Row_lengths(y));
}

static int lua_Row_eq(lua_State *L) {
    int args = lua_gettop(L);
    if (args != 2) {
        return luaL_error(L, "to compare rows, I need 2 rows");
    }
    if (!lua_isuserdata(L, 2)) {
        return luaL_error(L, "compare a Row to Row");
    }
    Row* x = lua_touserdata(L, 1);
    Row* y = lua_touserdata(L, 2);
    int result = Row_eq(x, y);
    lua_pushboolean(L, result);
    return 1;
}

static int lua_Row_type(lua_State *L) {
    lua_pushstring(L, "Row");
    return 1;
}

static int Row_length(Row* self) {
    int last_index = self->len_ - 1;
    return Row_starts(self)[last_index];
}

static int lua_Row_length(lua_State *L) {
    Row* self = lua_touserdata(L, 1);
    int length = Row_length(self);
    lua_pushnumber(L, length);
    return 1;
}

static int Row_fragment_length(Row* self) {
    int last_index = self->len_ - 1;
    return Row_lengths(self)[last_index];
}

static int lua_Row_fragment_length(lua_State *L) {
    Row* self = lua_touserdata(L, 1);
    int fragment_length = Row_fragment_length(self);
    lua_pushnumber(L, fragment_length);
    return 1;
}

static char* Row_text(Row* self, const char* fragment) {
    // if fragment == 0, use N for each position
    int* starts = Row_starts(self);
    int* lengths = Row_lengths(self);
    int row_length = Row_length(self);
    char* result = malloc(row_length);
    int cur = 0;
    int groups = self->len_;
    int i;
    for (i = 0; i < groups - 1; i++) {
        int bp = starts[i];
        while (cur < bp) {
            result[cur] = '-';
            cur++;
        }
        int start = lengths[i];
        int stop = lengths[i + 1] - 1;
        int j;
        for (j = start; j <= stop; j++) {
            if (fragment) {
                result[cur] = fragment[j];
            } else {
                result[cur] = 'N';
            }
            cur++;
        }
    }
    // last group
    while (cur < row_length) {
        result[cur] = '-';
        cur++;
    }
    assert(cur == row_length);
    return result;
}

static int lua_Row_text(lua_State *L) {
    Row* self = lua_touserdata(L, 1);
    const char* fragment = 0;
    int args = lua_gettop(L);
    if (args == 2) {
        if (!lua_isstring(L, 2)) {
            return luaL_error(L, "call Row:text(string)");
        }
        size_t len;
        fragment = lua_tolstring(L, 2, &len);
        if (len != Row_fragment_length(self)) {
            return luaL_error(L, "Row:text: bad length");
        }
    }
    char* result = Row_text(self, fragment);
    int row_length = Row_length(self);
    lua_pushlstring(L, result, row_length);
    return 1;
}

static int upper(int* list, int len, int value) {
    int first = 0;
    int count = len;
    while (count > 0) {
        int step = count / 2;
        int it = first + step;
        if (!(value < list[it])) {
            first = it + 1;
            count = count - step - 1;
        } else {
            count = step;
        }
    }
    return first;
}

static int Row_block2fragment(Row* self, int blockpos) {
    int* starts = Row_starts(self);
    int* lengths = Row_lengths(self);
    int row_length = Row_length(self);
    assert(blockpos >= 0);
    assert(blockpos < row_length);
    int index = upper(starts, self->len_, blockpos) - 1;
    if (index == -1) {
        // we are in a gap before first letter
        return -1;
    }
    int group_length = lengths[index + 1] - lengths[index];
    int distance = blockpos - starts[index];
    if (distance < group_length) {
        return lengths[index] + distance;
    } else {
        return -1;
    }
}

static int lua_Row_block2fragment(lua_State *L) {
    int args = lua_gettop(L);
    if (args != 2) {
        return luaL_error(L, "call Row:block2fragment(int)");
    }
    if (!lua_isnumber(L, 2)) {
        return luaL_error(L, "call Row:block2fragment(int)");
    }
    Row* self = lua_touserdata(L, 1);
    int bp = lua_tonumber(L, 2);
    if (bp < 0 || bp >= Row_length(self)) {
        return luaL_error(L, "block2fragment: out of range");
    }
    int result = Row_block2fragment(self, bp);
    lua_pushnumber(L, result);
    return 1;
}

static int Row_block2left(Row* self, int blockpos) {
    int* starts = Row_starts(self);
    int* lengths = Row_lengths(self);
    int row_length = Row_length(self);
    assert(blockpos >= 0);
    assert(blockpos < row_length);
    int index = upper(starts, self->len_, blockpos) - 1;
    if (index == -1) {
        // we are in a gap before first letter
        return -1;
    }
    int group_length = lengths[index + 1] - lengths[index];
    int distance = blockpos - starts[index];
    if (distance < group_length) {
        return lengths[index] + distance;
    } else {
        // last member of the group
        return lengths[index + 1] - 1;
    }
}

static int lua_Row_block2left(lua_State *L) {
    int args = lua_gettop(L);
    if (args != 2) {
        return luaL_error(L, "call Row:block2left(int)");
    }
    if (!lua_isnumber(L, 2)) {
        return luaL_error(L, "call Row:block2left(int)");
    }
    Row* self = lua_touserdata(L, 1);
    int bp = lua_tonumber(L, 2);
    if (bp < 0 || bp >= Row_length(self)) {
        return luaL_error(L, "block2left: out of range");
    }
    int result = Row_block2left(self, bp);
    lua_pushnumber(L, result);
    return 1;
}

static int Row_block2right(Row* self, int blockpos) {
    int* starts = Row_starts(self);
    int* lengths = Row_lengths(self);
    int row_length = Row_length(self);
    assert(blockpos >= 0);
    assert(blockpos < row_length);
    int index = upper(starts, self->len_, blockpos) - 1;
    if (index == -1) {
        // we are in a gap before first letter
        return 0;
    }
    int group_length = lengths[index + 1] - lengths[index];
    int distance = blockpos - starts[index];
    int last_index = self->len_ - 1;
    if (distance < group_length) {
        return lengths[index] + distance;
    } else if (index + 1 == last_index) {
        // after last group
        return -1;
    } else {
        // last member of the group
        return lengths[index + 1];
    }
}

static int lua_Row_block2right(lua_State *L) {
    int args = lua_gettop(L);
    if (args != 2) {
        return luaL_error(L, "call Row:block2right(int)");
    }
    if (!lua_isnumber(L, 2)) {
        return luaL_error(L, "call Row:block2right(int)");
    }
    Row* self = lua_touserdata(L, 1);
    int bp = lua_tonumber(L, 2);
    if (bp < 0 || bp >= Row_length(self)) {
        return luaL_error(L, "block2right: out of range");
    }
    int result = Row_block2right(self, bp);
    lua_pushnumber(L, result);
    return 1;
}

static int Row_block2nearest(Row* self, int blockpos) {
    int* starts = Row_starts(self);
    int* lengths = Row_lengths(self);
    int row_length = Row_length(self);
    assert(blockpos >= 0);
    assert(blockpos < row_length);
    int index = upper(starts, self->len_, blockpos) - 1;
    if (index == -1) {
        // we are in a gap before first letter
        return 0;
    }
    int group_length = lengths[index + 1] - lengths[index];
    int distance = blockpos - starts[index];
    int last_index = self->len_ - 1;
    if (distance < group_length) {
        return lengths[index] + distance;
    } else if (index + 1 == last_index) {
        // after last group
        return lengths[last_index] - 1;
    } else {
        int left_distance = distance - group_length + 1;
        int right_distance = starts[index + 1] - blockpos;
        if (left_distance <= right_distance) {
            return lengths[index + 1] - 1;
        } else {
            return lengths[index + 1];
        }
    }
}

static int lua_Row_block2nearest(lua_State *L) {
    int args = lua_gettop(L);
    if (args != 2) {
        return luaL_error(L, "call Row:block2nearest(int)");
    }
    if (!lua_isnumber(L, 2)) {
        return luaL_error(L, "call Row:block2nearest(int)");
    }
    Row* self = lua_touserdata(L, 1);
    int bp = lua_tonumber(L, 2);
    if (bp < 0 || bp >= Row_length(self)) {
        return luaL_error(L, "block2nearest: out of range");
    }
    int result = Row_block2nearest(self, bp);
    lua_pushnumber(L, result);
    return 1;
}

static int Row_fragment2block(Row* self, int fragmentpos) {
    int* starts = Row_starts(self);
    int* lengths = Row_lengths(self);
    int fragment_length = Row_fragment_length(self);
    assert(fragmentpos >= 0);
    assert(fragmentpos < fragment_length);
    int index = upper(lengths, self->len_, fragmentpos) - 1;
    int distance = fragmentpos - lengths[index];
    return starts[index] + distance;
}

static int lua_Row_fragment2block(lua_State *L) {
    int args = lua_gettop(L);
    if (args != 2) {
        return luaL_error(L, "call Row:fragment2block(int)");
    }
    if (!lua_isnumber(L, 2)) {
        return luaL_error(L, "call Row:fragment2block(int)");
    }
    Row* self = lua_touserdata(L, 1);
    int fp = lua_tonumber(L, 2);
    if (fp < 0 || fp >= Row_fragment_length(self)) {
        return luaL_error(L, "fragment2block: out of range");
    }
    int result = Row_fragment2block(self, fp);
    lua_pushnumber(L, result);
    return 1;
}

static const luaL_Reg rowlib[] = {
    {"__eq", lua_Row_eq},
    {"type", lua_Row_type},
    {"length", lua_Row_length},
    {"fragment_length", lua_Row_fragment_length},
    {"text", lua_Row_text},
    {"block2fragment", lua_Row_block2fragment},
    {"block2left", lua_Row_block2left},
    {"block2right", lua_Row_block2right},
    {"block2nearest", lua_Row_block2nearest},
    {"fragment2block", lua_Row_fragment2block},
    {NULL, NULL}
};

LUALIB_API int luaopen_npge_model_cRow(lua_State *L) {
    // row_mt
    lua_newtable(L);
    luaL_register(L, NULL, rowlib);
    lua_pushvalue(L, -1);
    lua_setfield(L, -2, "__index"); // mt.__index = mt
    // constructor
    lua_pushcclosure(L, lua_Row_constructor, 1);
    // Row_mt
    lua_newtable(L);
    lua_pushvalue(L, -2); // constructor
    // Row_mt.__call = constructor
    lua_setfield(L, -2, "__call");
    // module Row
    lua_newtable(L);
    lua_pushvalue(L, -2); // Row_mt
    lua_setmetatable(L, -2);
    return 1; // module Row
}
