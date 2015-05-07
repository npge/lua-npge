/* lua-npge, Nucleotide PanGenome explorer (Lua module)
 * Copyright (C) 2014-2015 Boris Nagaev
 * See the LICENSE file for terms of use.
 */

#include <cstring>
#include <boost/algorithm/string/join.hpp>

#include "npge.hpp"
#include "cast.hpp"

namespace lnpge {

static const unsigned char COMPLEMENT_MAP[] = {
0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16,
17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31,
32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46,
47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61,
62, 63, 64, 'T', 66, 'G', 68, 69, 70, 'C', 72, 73, 74, 75,
76, 77, 78, 79, 80, 81, 82, 83, 'A', 85, 86, 87, 88, 89,
90, 91, 92, 93, 94, 95, 96, 't', 98, 'g', 100, 101, 102,
'c', 104, 105, 106, 107, 108, 109, 110, 111, 112, 113, 114,
115, 'a', 117, 118, 119, 120, 121, 122, 123, 124, 125, 126,
127, 128, 129, 130, 131, 132, 133, 134, 135, 136, 137, 138,
139, 140, 141, 142, 143, 144, 145, 146, 147, 148, 149, 150,
151, 152, 153, 154, 155, 156, 157, 158, 159, 160, 161, 162,
163, 164, 165, 166, 167, 168, 169, 170, 171, 172, 173, 174,
175, 176, 177, 178, 179, 180, 181, 182, 183, 184, 185, 186,
187, 188, 189, 190, 191, 192, 193, 194, 195, 196, 197, 198,
199, 200, 201, 202, 203, 204, 205, 206, 207, 208, 209, 210,
211, 212, 213, 214, 215, 216, 217, 218, 219, 220, 221, 222,
223, 224, 225, 226, 227, 228, 229, 230, 231, 232, 233, 234,
235, 236, 237, 238, 239, 240, 241, 242, 243, 244, 245, 246,
247, 248, 249, 250, 251, 252, 253, 254, 255
};

static const unsigned char ATGCN_MAP[] = {
0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
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

// A => 1, T => 2, G => 3, C => 4, N => 0, other => 0
static const unsigned char TOINT_MAP[] = {
0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
0, 0, 0, 0, 0, 1, 0, 4, 0, 0, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0,
0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 4,
0, 0, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0,
0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
};
const int TOINT_MAX = 5;
static const unsigned char FROMINT_MAP[] = {
0, 'A', 'T', 'G', 'C', 'N'
};

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

int complement(char* dst, const char* src, int length) {
    for (int i = 0; i < length; i++) {
        int i1 = length - i - 1;
        unsigned char c = src[i];
        dst[i1] = COMPLEMENT_MAP[c];
    }
    return length;
}

int toAtgcn(char* dst, const char* src, int length) {
    int dst_i = 0;
    for (int src_i = 0; src_i < length; src_i++) {
        unsigned char c = src[src_i];
        char c1 = ATGCN_MAP[c];
        if (c1) {
            dst[dst_i] = c1;
            dst_i += 1;
        }
    }
    return dst_i;
}

int toAtgcnAndGap(char* dst, const char* src, int length) {
    int dst_i = 0;
    for (int src_i = 0; src_i < length; src_i++) {
        unsigned char c = src[src_i];
        char c1 = ATGCN_GAP_MAP[c];
        if (c1) {
            dst[dst_i] = c1;
            dst_i += 1;
        }
    }
    return dst_i;
}

// arguments:
// 1. row
// 2. orig
// returns length of result
int unwindRow(char* result, const char* row, int row_size,
              const char* orig, int orig_size) {
    int orig_i = 0;
    int i;
    for (i = 0; i < row_size; i++) {
        char c = row[i];
        if (c == '-') {
            result[i] = '-';
        } else {
            if (orig_i >= orig_size) {
                // Length of original row is not sufficient
                return -1;
            }
            result[i] = orig[orig_i];
            orig_i += 1;
        }
    }
    if (orig_i != orig_size) {
        // Original row is too long
        return -1;
    }
    return row_size;
}

bool isColumnGood(const char** rows, int nrows, int i) {
    assert(nrows > 0);
    char first = rows[0][i];
    if (first == '-' || first == 'N') {
        return false;
    }
    for (int irow = 0; irow < nrows; irow++) {
        char letter = rows[irow][i];
        if (letter != first) {
            return false;
        }
    }
    return true;
}

double identity(const char** rows, int nrows,
                int start, int stop) {
    double ident = 0;
    for (int i = start; i <= stop; i++) {
        if (isColumnGood(rows, nrows, i)) {
            ident += 1;
        }
    }
    return ident;
}

char consensusAtPos(const char** rows, int nrows, int i) {
    int count[TOINT_MAX + 1] = {0, 0, 0, 0, 0, 0};
    for (int irow = 0; irow < nrows; irow++) {
        char letter = rows[irow][i];
        int index = TOINT_MAP[letter];
        count[index] += 1;
    }
    const int A = TOINT_MAP['A'];
    const int N = TOINT_MAX;
    int max_index = N; // N is the default
    // but it is overcomed by all other bases,
    // because count[N] = 0
    for (int index = A; index < N; index++) {
        if (count[index] > count[max_index]) {
            max_index = index;
        }
    }
    return FROMINT_MAP[max_index];
}

// size of dst is length. 0 byte is not required
void consensus(char* dst, const char** rows,
               int nrows, int length) {
    for (int i = 0; i < length; i++) {
        dst[i] = consensusAtPos(rows, nrows, i);
    }
}

std::string stripLastComma(std::stringstream& ss) {
    std::string result = ss.str();
    if (!result.empty() && result[result.size() - 1] == ',') {
        result.resize(result.size() - 1);
    }
    return result;
}

// size of dst is at least length + 2, 0 byte is not required
int ShortForm_diff(char* dst, const char* consensus,
                   const char* text, int length) {
    Strings A, T, G, C, N, gap, _;
    for (int i = 0; i < length; i++) {
        char c = consensus[i];
        char t = text[i];
        if (t != c) {
            Strings& ss =
                (t == 'A') ? A :
                (t == 'T') ? T :
                (t == 'G') ? G :
                (t == 'C') ? C :
                (t == 'N') ? N :
                (t == '-') ? gap : _;
            ss.push_back(TO_S(i));
        }
    }
    Strings results;
    using namespace boost::algorithm;
    if (!A.empty()) {
        results.push_back("A={" + join(A, ",") + "}");
    }
    if (!T.empty()) {
        results.push_back("T={" + join(T, ",") + "}");
    }
    if (!G.empty()) {
        results.push_back("G={" + join(G, ",") + "}");
    }
    if (!C.empty()) {
        results.push_back("C={" + join(C, ",") + "}");
    }
    if (!N.empty()) {
        results.push_back("N={" + join(N, ",") + "}");
    }
    if (!gap.empty()) {
        results.push_back("['-']={" + join(gap, ",") + "}");
    }
    std::string result_str = join(results, ",");
    if (result_str.size() < length) {
        dst[0] = '{';
        memcpy(dst + 1, result_str.c_str(), result_str.size());
        dst[result_str.size() + 1] = '}';
        return result_str.size() + 2;
    } else {
        dst[0] = '"';
        memcpy(dst + 1, text, length);
        dst[length + 1] = '"';
        return length + 2;
    }
}

}
