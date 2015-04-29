/* lua-npge, Nucleotide PanGenome explorer (Lua module)
 * Copyright (C) 2014-2015 Boris Nagaev
 * See the LICENSE file for terms of use.
 */

#include <cassert>
#include <algorithm>

#include "npge.hpp"

namespace lnpge {

// See https://en.wikipedia.org/wiki/Segment_tree
//                            0
//               1                         2
//        3           4              5             6
//     7     8     9     10    11       12      13      *14
// *0   *1 *2 *3 *4 *5 *6 *7 *8  *9 *10 *11 *12  *13

static int treeSize(int n) {
    // sum of 1, 2, 4, 8, ...
    return n - 1;
}

static int ceilLog2(int n) {
    if (n == 1) {
        return 1;
    } else {
        return 1 + ceilLog2(n / 2);
    }
}

static int pow2(int n) {
    return 1 << n;
}

struct SegmentTree {
    const Fragments& fragments_;
    Coordinates& tree_;
    int up_leafs_; // in exaple 1 leaf: 14

    SegmentTree(const Fragments& fragments,
                Coordinates& tree):
        fragments_(fragments), tree_(tree) {
        int leafs = fragments_.size(); // 15
        int leaf_slots = pow2(ceilLog2(leafs));
        assert(leaf_slots >= leafs);
        int lacking_leafs = leaf_slots - leafs;
        int down_leafs = leafs - lacking_leafs;
        up_leafs_ = leafs - down_leafs;
    }

    int leftChild(int node) const {
        return node * 2 + 1;
    }

    int rightChild(int node) const {
        return node * 2 + 2;
    }

    const FragmentPtr& getLeaf(int node) const {
        node -= tree_.size();
        if (node < up_leafs_) {
            node = fragments_.size() - up_leafs_ + node;
        } else {
            node = node - up_leafs_;
        }
        return fragments_[node];
    }

    const StartStop& getNode(int node) const {
        return tree_[node];
    }

    int getMin(int node) const {
        if (node < tree_.size()) {
            return getNode(node).first;
        } else {
            return fragmentMin(*getLeaf(node));
        }
    }

    int getMax(int node) const {
        if (node < tree_.size()) {
            return getNode(node).second;
        } else {
            return fragmentMax(*getLeaf(node));
        }
    }

    void build() {
        int leafs = fragments_.size(); // 15
        int nodes = treeSize(leafs); // 14
        tree_.resize(nodes);
        for (int node = nodes - 1; node >= 0; node--) {
            int min1 = getMin(leftChild(node));
            int max1 = getMax(leftChild(node));
            int min2 = getMin(rightChild(node));
            int max2 = getMax(rightChild(node));
            int min = std::min(min1, min2);
            int max = std::max(max1, max2);
            tree_[node] = StartStop(min, max);
        }
    }

    bool overlaps(const StartStop& pattern, int node) const {
        int min1 = getMin(node);
        int max1 = getMax(node);
        int min2 = pattern.first;
        int max2 = pattern.second;
        if (min1 <= min2 && min2 <= max1) {
            return true;
        }
        if (min2 <= min1 && min1 <= max2) {
            return true;
        }
        return false;
    }

    void find(Fragments& result, const StartStop& pattern,
              int node) const {
        if (node >= fragments_.size() + tree_.size()) {
            return;
        }
        if (!overlaps(pattern, node)) {
            return;
        }
        if (node >= tree_.size()) {
            result.push_back(getLeaf(node));
        }
        find(result, pattern, leftChild(node));
        find(result, pattern, rightChild(node));
    }

    void findOverlapping(Fragments& result,
                         const StartStop& pattern) const {
        find(result, pattern, 0);
    }
};

void makeSegmentTree(Coordinates& tree,
                     const Fragments& fragments) {
    SegmentTree st(fragments, tree);
    st.build();
}

void findOverlapping(Fragments& result,
                     const Coordinates& tree,
                     const Fragments& fragments,
                     const FragmentPtr& fragment) {
    SegmentTree st(fragments, const_cast<Coordinates&>(tree));
    int min = fragmentMin(*fragment);
    int max = fragmentMax(*fragment);
    st.findOverlapping(result, StartStop(min, max));
}

}
