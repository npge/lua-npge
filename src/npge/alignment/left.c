#include <stdlib.h>
#include <string.h>
#include <assert.h>

#define LUA_LIB
#include <lua.h>
#include <lauxlib.h>

typedef struct {
    // aligned points to of nrows times max_row_len cated
    char* aligned;
    const char** rows;
    int* lens;
    int* used_row;
    int* used_aln;
    int nrows;
    int max_row_len;
    int MISMATCH_CHECK;
    int GAP_CHECK;
    int right_aligned;
    int identical_group;
} Aln;

static char* alignedRow(Aln* aln, int irow) {
    return aln->aligned + irow * aln->max_row_len;
}

static int exists(Aln* aln, int irow) {
    return aln->used_row[irow] < aln->lens[irow];
}

static int anyExists(Aln* aln) {
    int irow;
    for (irow = 0; irow < aln->nrows; irow++) {
        if (exists(aln, irow)) {
            return 1;
        }
    }
    return 0;
}

static int allExist(Aln* aln) {
    int irow;
    for (irow = 0; irow < aln->nrows; irow++) {
        if (!exists(aln, irow)) {
            return 0;
        }
    }
    return 1;
}

static char nextChar(Aln* aln, int irow) {
    const char* row = aln->rows[irow];
    int used = aln->used_row[irow];
    return row[used];
}

static int isIdentical(Aln* aln) {
    char first = nextChar(aln, 0);
    int irow;
    for (irow = 1; irow < aln->nrows; irow++) {
        if (nextChar(aln, irow) != first) {
            return 0;
        }
    }
    return 1;
}

static int identicalLeft(Aln* aln, int n_cols) {
    return aln->identical_group >= n_cols;
}

static int identicalRight0(Aln* aln, int n_cols,
        int* used_row, int shift) {
    int first_len = aln->lens[0] - (used_row[0] + shift);
    if (first_len < n_cols && !aln->right_aligned) {
        return 0;
    }
    int cmp_len = n_cols;
    if (first_len < n_cols) {
        cmp_len = first_len;
    }
    const char* first = aln->rows[0] + (used_row[0] + shift);
    int irow;
    for (irow = 1; irow < aln->nrows; irow++) {
        int len = aln->lens[irow] - (used_row[irow] + shift);
        if (len < cmp_len) {
            return 0;
        }
        const char* row = aln->rows[irow] +
            (used_row[irow] + shift);
        if (memcmp(first, row, cmp_len) != 0) {
            return 0;
        }
    }
    return 1;
}

static int identicalAround(Aln* aln, int n_cols) {
    return identicalLeft(aln, n_cols) &&
        identicalRight0(aln, n_cols, aln->used_row, 1);
}

int* makeUsedRowsForGap(Aln* aln, char c) {
    int* used = malloc(aln->nrows * sizeof(int*));
    int irow;
    for (irow = 0; irow < aln->nrows; irow++) {
        if (exists(aln, irow) && nextChar(aln, irow) == c) {
            // "move" this char
            used[irow] = aln->used_row[irow] + 1;
        } else {
            used[irow] = aln->used_row[irow];
        }
    }
    return used;
}

static const char* LETTERS = "ATGCN";
const int NLETTERS = 5;

int* getSome(int** variants) {
    int i;
    for (i = 0; i < NLETTERS; i++) {
        if (variants[i]) {
            return variants[i];
        }
    }
    return 0;
}

int* getBestVariant(Aln* aln, int** variants0) {
    int* variants[NLETTERS];
    memcpy(variants, variants0, NLETTERS * sizeof(int*));
    int n;
    int GAP_CHECK = aln->GAP_CHECK;
    for (n = GAP_CHECK + 1; n < 10 * GAP_CHECK; n++) {
        int* variants1[NLETTERS];
        int variants_found = 0;
        int i;
        for (i = 0; i < NLETTERS; i++) {
            int* used = variants[i];
            if (used && identicalRight0(aln, n, used, 0)) {
                variants1[i] = used;
                variants_found += 1;
            } else {
                variants1[i] = 0;
            }
        }
        if (variants_found == 1) {
            return getSome(variants1);
        } else if (variants_found == 0) {
            return getSome(variants);
        } else {
            memcpy(variants, variants1,
                    NLETTERS * sizeof(int*));
        }
    }
    return getSome(variants0);
}

int* findBestGap(Aln* aln) {
    int* variants[NLETTERS];
    int variants_found = 0;
    int i;
    for (i = 0; i < NLETTERS; i++) {
        int* used = makeUsedRowsForGap(aln, LETTERS[i]);
        if (identicalRight0(aln, aln->GAP_CHECK, used, 0)) {
            variants[i] = used;
            variants_found += 1;
        } else {
            variants[i] = 0;
            free(used);
        }
    }
    if (variants_found == 1) {
        return getSome(variants);
    } else if (variants_found == 0) {
        return 0;
    }
    int* variant = getBestVariant(aln, variants);
    for (i = 0; i < NLETTERS; i++) {
        if (variants[i] != variant) {
            free(variants[i]);
        }
    }
    return variant;
}

void putChar(Aln* aln, int irow, char c) {
    int used_aln = aln->used_aln[irow];
    assert(used_aln < aln->max_row_len);
    char* row = alignedRow(aln, irow);
    row[used_aln] = c;
    aln->used_aln[irow] += 1;
}

void moveChar(Aln* aln, int irow) {
    int used_row = aln->used_row[irow];
    assert(used_row < aln->lens[irow]);
    char c = aln->rows[irow][used_row];
    putChar(aln, irow, c);
    aln->used_row[irow] += 1;
}

void moveWholeRow(Aln* aln) {
    int irow;
    for (irow = 0; irow < aln->nrows; irow++) {
        moveChar(aln, irow);
    }
}

void moveGap(Aln* aln, int* used_row) {
    int irow;
    for (irow = 0; irow < aln->nrows; irow++) {
        if (used_row[irow] == aln->used_row[irow]) {
            putChar(aln, irow, '-');
        } else {
            moveChar(aln, irow);
        }
    }
    assert(memcmp(used_row, aln->used_row,
                aln->nrows * sizeof(int)) == 0);
}

static void alignLeft(Aln* aln) {
    aln->identical_group = aln->GAP_CHECK + aln->MISMATCH_CHECK;
    while (anyExists(aln)) {
        if (allExist(aln) && isIdentical(aln)) {
            moveWholeRow(aln);
            aln->identical_group += 1;
        } else {
            int ok = 0;
            if (allExist(aln) && identicalAround(aln,
                        aln->MISMATCH_CHECK)) {
                moveWholeRow(aln);
                ok = 1;
            } else if (identicalLeft(aln, aln->GAP_CHECK)) {
                int* new_used = findBestGap(aln);
                if (new_used) {
                    moveGap(aln, new_used);
                    free(new_used);
                    ok = 1;
                }
            }
            if (!ok) {
                break;
            }
            aln->identical_group = 0;
        }
    }
}

// arguments:
// 1. Lua table with rows
// results:
// 1. Lua table with alignment
// 2. Lua table with remaining parts of rows (tails)
static int lua_left(lua_State *L) {
    Aln aln;
    luaL_checktype(L, 1, LUA_TTABLE);
    aln.right_aligned = lua_toboolean(L, 2);
    aln.nrows = lua_objlen(L, 1);
    if (aln.nrows == 0) {
        lua_newtable(L); // prefixes
        lua_newtable(L); // tails
        return 2;
    }
    aln.rows = malloc(aln.nrows * sizeof(const char*));
    aln.lens = malloc(aln.nrows * sizeof(size_t));
    // populate rows
    size_t min_len;
    int irow;
    for (irow = 0; irow < aln.nrows; irow++) {
        lua_rawgeti(L, 1, irow + 1);
        size_t len;
        const char* row = luaL_checklstring(L, -1, &len);
        aln.rows[irow] = row;
        aln.lens[irow] = len;
        if (irow == 0 || len < min_len) {
            min_len = len;
        }
        lua_pop(L, 1);
    }
    // read config
    lua_getglobal(L, "require");
    lua_pushliteral(L, "npge.config");
    lua_call(L, 1, 1);
    lua_getfield(L, -1, "alignment");
    lua_getfield(L, -1, "MISMATCH_CHECK");
    aln.MISMATCH_CHECK = luaL_checkint(L, -1);
    lua_getfield(L, -2, "GAP_CHECK");
    aln.GAP_CHECK = luaL_checkint(L, -1);
    // make alignment
    aln.max_row_len = min_len * 2 + aln.GAP_CHECK * 2;
    aln.aligned = malloc(aln.max_row_len * aln.nrows);
    aln.used_aln = malloc(aln.nrows * sizeof(size_t));
    aln.used_row = malloc(aln.nrows * sizeof(size_t));
    memset(aln.used_aln, 0, aln.nrows * sizeof(size_t));
    memset(aln.used_row, 0, aln.nrows * sizeof(size_t));
    // align
    alignLeft(&aln);
    // push results
    lua_createtable(L, aln.nrows, 0); // aligned
    lua_createtable(L, aln.nrows, 0); // tails
    for (irow = 0; irow < aln.nrows; irow++) {
        lua_pushlstring(L, alignedRow(&aln, irow),
                aln.used_aln[irow]); // aligned
        lua_rawseti(L, -3, irow + 1);
        //
        int used = aln.used_row[irow];
        lua_pushlstring(L, aln.rows[irow] + used,
                aln.lens[irow] - used); // tail
        lua_rawseti(L, -2, irow + 1);
    }
    free(aln.aligned);
    free(aln.rows);
    free(aln.lens);
    free(aln.used_row);
    free(aln.used_aln);
    return 2;
}

LUALIB_API int luaopen_npge_alignment_cleft(
        lua_State *L) {
    lua_pushcfunction(L, lua_left);
    return 1;
}
