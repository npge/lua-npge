/*
 * NPG-explorer, Nucleotide PanGenome explorer
 * Copyright (C) 2012-2015 Boris Nagaev
 *
 * See the LICENSE file for terms of use.
 */

#include <string.h>
#include <map>

#include "npge.hpp"

namespace lnpge {

char* alignedRow(Aln* aln, int irow) {
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

static int* makeUsedRowsForGap(Aln* aln, char c) {
    int* used = reinterpret_cast<int*>(
            malloc(aln->nrows * sizeof(int*)));
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

static int* getSome(int** variants) {
    int i;
    for (i = 0; i < NLETTERS; i++) {
        if (variants[i]) {
            return variants[i];
        }
    }
    return 0;
}

static int* getBestVariant(Aln* aln, int** variants0) {
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

static int* findBestGap(Aln* aln) {
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
    if (variants_found == 1 || variants_found == 0) {
        return getSome(variants);
    }
    int* variant = getBestVariant(aln, variants);
    for (i = 0; i < NLETTERS; i++) {
        if (variants[i] != variant) {
            free(variants[i]);
        }
    }
    return variant;
}

static void putChar(Aln* aln, int irow, char c) {
    int used_aln = aln->used_aln[irow];
    assert(used_aln < aln->max_row_len);
    char* row = alignedRow(aln, irow);
    row[used_aln] = c;
    aln->used_aln[irow] += 1;
}

static void moveChar(Aln* aln, int irow) {
    int used_row = aln->used_row[irow];
    assert(used_row < aln->lens[irow]);
    char c = aln->rows[irow][used_row];
    putChar(aln, irow, c);
    aln->used_row[irow] += 1;
}

static void moveWholeRow(Aln* aln) {
    int irow;
    for (irow = 0; irow < aln->nrows; irow++) {
        moveChar(aln, irow);
    }
}

static void moveGap(Aln* aln, int* used_row) {
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

void alignLeft(Aln* aln) {
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

/////

static int maxLength(int nrows, const int* lens) {
    int max_len;
    for (int irow = 0; irow < nrows; irow++) {
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

typedef std::vector<int> Ints;
typedef std::map<int, Ints> Number2Pos;
typedef std::map<std::string, Ints> String2Pos;

static void newPos(Ints& pos, int nrows) {
    pos.resize(nrows + 1, -1);
    pos[nrows] = 0;
}

// compare all rows. If all are equal, returns 1
bool compareWords(int nrows, const char** rows,
        const int* lens, int ANCHOR, int start) {
    if (start + ANCHOR > lens[0]) {
        return false;
    }
    const char* first = rows[0] + start;
    for (int irow = 1; irow < nrows; irow++) {
        int len = lens[irow];
        if (start + ANCHOR > len) {
            return false;
        }
        const char* word = rows[irow] + start;
        if (memcmp(first, word, ANCHOR) != 0) {
            return false;
        }
    }
    return true;
}

template <typename T>
Ints& getByKey(T& dict, int nrows,
               const char* word, int ANCHOR) {
}

static int wordToNumber(const char* word, int len) {
    int value = 0;
    for (int i = 0; i < len; i++) {
        unsigned char c = word[i];
        value *= POSSIBLE_LETTERS;
        value += LETTER_TO_NUMBER[c];
    }
    return value;
}

template <>
Ints& getByKey(Number2Pos& dict, int nrows,
        const char* word, int ANCHOR) {
    int n = wordToNumber(word, ANCHOR);
    Ints& result = dict[n];
    if (result.empty()) {
        newPos(result, nrows);
    }
    return result;
}

template <>
Ints& getByKey(String2Pos& dict, int nrows,
        const char* word, int ANCHOR) {
    std::string n((word), ANCHOR);
    Ints& result = dict[n];
    if (result.empty()) {
        newPos(result, nrows);
    }
    return result;
}

// return if an anchor was found
template <typename T>
bool addWords(int* result, T& dict, int nrows,
        const char** rows, const int* lens,
        int ANCHOR, int start) {
    // compare all rows. If all are equal, returns this
    if (compareWords(nrows, rows, lens, ANCHOR, start)) {
        for (int irow = 0; irow < nrows; irow++) {
            result[irow] = start;
        }
        return true;
    }
    // compare to known words
    for (int irow = 0; irow < nrows; irow++) {
        int len = lens[irow];
        if (start + ANCHOR <= len) {
            const char* word = rows[irow] + start;
            Ints& pos = getByKey<T>(dict, nrows, word, ANCHOR);
            if (pos[irow] == -1) {
                pos[irow] = start;
                pos[nrows] += 1;
                if (pos[nrows] == nrows) {
                    for (int irow = 0; irow < nrows; irow++) {
                        result[irow] = pos[irow];
                    }
                    return true;
                }
            }
        }
    }
    return false;
}

template <typename T>
bool findAnchorImpl(int* result, T& dict,
        int nrows, const char** rows,
        const int* lens, int ANCHOR, int last) {
    for (int start = 0; start <= last; start++) {
        if (addWords(result, dict, nrows, rows, lens,
                     ANCHOR, start)) {
            return true;
        }
    }
    return false;
}

// returns if the anchor was found
// result is int[nrows], list of anchor starts
bool findAnchor(int* result, int nrows, const char** rows,
        const int* lens, int ANCHOR, int MIN_LENGTH) {
    int max_len = maxLength(nrows, lens);
    int last = max_len - ANCHOR;
    if (last > MIN_LENGTH) {
        last = MIN_LENGTH;
    }
    if (ANCHOR <= MAX_NUMBER_ANCHOR) {
        Number2Pos dict;
        return findAnchorImpl(result, dict, nrows, rows,
                lens, ANCHOR, last);
    } else {
        String2Pos dict;
        return findAnchorImpl(result, dict, nrows, rows,
                lens, ANCHOR, last);
    }
}

}
