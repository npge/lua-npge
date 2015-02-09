/*
 * NPG-explorer, Nucleotide PanGenome explorer
 * Copyright (C) 2012-2015 Boris Nagaev
 *
 * See the LICENSE file for terms of use.
 */

#include <cmath>
#include <cstring>
#include <algorithm>
#include <iterator>
#include <map>
#include <boost/foreach.hpp>
#include <boost/scoped_array.hpp>
#include <boost/tuple/tuple.hpp>
#include <boost/tuple/tuple_comparison.hpp>
#include <boost/algorithm/string/split.hpp>
#include <boost/algorithm/string/classification.hpp>

#include "model.hpp"
#include "throw_assert.hpp"
#include "cast.hpp"

namespace npge {

typedef boost::scoped_array<char> Buffer;

typedef std::vector<int> Ints;

static void range(Ints& ints, int n) {
    ints.resize(n);
    for (int i = 0; i < n; i++) {
        ints[i] = i;
    }
}

template<typename It, typename V, typename Cmp>
It binarySearch(It begin, It end, const V& v, const Cmp& less) {
    It it = std::lower_bound(begin, end, v, less);
    if (it != end && less(v, *it)) {
        it = end;
    }
    return it;
}

template<typename It, typename V>
It binarySearch(It begin, It end, const V& v) {
    It it = std::lower_bound(begin, end, v);
    if (it != end && !(*it == v)) {
        it = end;
    }
    return it;
}

struct IndexedFragmentLess {
    IndexedFragmentLess(const Fragments& fragments):
        fragments_(fragments) {
    }

    bool operator()(int a, int b) const {
        return *(fragments_[a]) < *(fragments_[b]);
    }

    const Fragments& fragments_;
};

///////

Sequence::Sequence() {
}

SequencePtr Sequence::make(const std::string& name,
                           const std::string& description,
                           const char* text, int len) {
    Buffer b(new char[len]);
    int b_len = toAtgcn(b.get(), text, len);
    ASSERT_MSG(name.length(), "No unknown sequences allowed");
    ASSERT_MSG(b_len, "No empty sequences allowed");
    Sequence* seq = new Sequence;
    seq->text_.assign(b.get(), b_len);
    seq->name_ = name;
    seq->description_ = description;
    return SequencePtr(seq);
}

const std::string& Sequence::name() const {
    return name_;
}

const std::string& Sequence::description() const {
    return description_;
}

std::string Sequence::genome() const {
    using namespace boost::algorithm;
    Strings parts;
    split(parts, name(), is_any_of("&"));
    if (parts.size() == 3) {
        return parts[0];
    } else {
        return "";
    }
}

std::string Sequence::chromosome() const {
    using namespace boost::algorithm;
    Strings parts;
    split(parts, name(), is_any_of("&"));
    if (parts.size() == 3) {
        return parts[1];
    } else {
        return "";
    }
}

bool Sequence::circular() const {
    using namespace boost::algorithm;
    Strings parts;
    split(parts, name(), is_any_of("&"));
    return (parts.size() == 3 && parts[2].length() >= 1 &&
            parts[2][0] == 'c');
}

int Sequence::length() const {
    return text_.length();
}

const std::string& Sequence::text() const {
    return text_;
}

std::string Sequence::sub(int min, int max) const {
    ASSERT_LTE(0, min);
    ASSERT_LTE(min, max);
    ASSERT_LT(max, length());
    int len = max - min + 1;
    return text_.substr(min, len);
}

std::string Sequence::tostring() const {
    return "Sequence " + name() +
           " of length " + TO_S(length());
}

bool Sequence::operator==(const Sequence& other) const {
    return name() == other.name();
}

Fragment::Fragment() {
}

FragmentPtr Fragment::make(SequencePtr sequence,
                           int start, int stop, int ori) {
    ASSERT_TRUE(sequence);
    ASSERT_LTE(0, start);
    ASSERT_LT(start, sequence->length());
    ASSERT_LTE(0, stop);
    ASSERT_LT(stop, sequence->length());
    ASSERT_TRUE(ori == 1 || ori == -1);
    Fragment* fragment = new Fragment;
    fragment->sequence_ = sequence;
    fragment->start_ = start;
    fragment->stop_ = (stop + 1) * ori;
    FragmentPtr fr(fragment);
    if (!sequence->circular()) {
        ASSERT_MSG(!fragment->parted(), "Found parted "
                   "fragment on linear sequence");
    }
    return fr;
}

const SequencePtr& Fragment::sequence() const {
    return sequence_;
}

int Fragment::start() const {
    return start_;
}

int Fragment::stop() const {
    return abs(stop_) - 1;
}

int Fragment::ori() const {
    return (stop_ < 0) ? -1 : 1;
}

bool Fragment::parted() const {
    int diff = stop() - start();
    return diff * ori() < 0;
}

int Fragment::length() const {
    int absdiff = abs(stop() - start());
    if (!parted()) {
        return absdiff + 1;
    } else {
        return sequence()->length() - absdiff + 1;
    }
}

std::string Fragment::id() const {
    return sequence()->name() + "_" + TO_S(start()) + "_" +
        TO_S(stop()) + "_" + TO_S(ori());
}

std::string Fragment::tostring() const {
    std::string text = "Fragment " + id() +
        " of length " + TO_S(length());
    if (parted()) {
        text += " (parted)";
    }
    return text;
}

TwoFragments Fragment::parts() const {
    ASSERT_TRUE(parted());
    const SequencePtr& seq = sequence();
    int last = seq->length() - 1;
    if (ori() == 1) {
        return TwoFragments(
                Fragment::make(seq, start(), last, 1),
                Fragment::make(seq, 0, stop(), 1));
    } else {
        return TwoFragments(
                Fragment::make(seq, start(), 0, -1),
                Fragment::make(seq, last, stop(), -1));
    }
}

std::string Fragment::text() const {
    if (!parted()) {
        int min = std::min(start(), stop());
        int max = std::max(start(), stop());
        std::string text = sequence()->sub(min, max);
        if (ori() == 1) {
            return text;
        } else {
            Buffer b(new char[text.size()]);
            int l = complement(b.get(), text.c_str(),
                    text.size());
            return std::string(b.get(), l);
        }
    } else {
        TwoFragments two = parts();
        return two.first->text() + two.second->text();
    }
}

int Fragment::common(const Fragment& other) const {
    if (parted()) {
        TwoFragments two = parts();
        return two.first->common(other) +
               two.second->common(other);
    }
    if (other.parted()) {
        TwoFragments two = other.parts();
        return common(*two.first) + common(*two.second);
    }
    int self_min = std::min(start(), stop());
    int self_max = std::max(start(), stop());
    int other_min = std::min(other.start(), other.stop());
    int other_max = std::max(other.start(), other.stop());
    int common_min = std::max(self_min, other_min);
    int common_max = std::min(self_max, other_max);
    int common = common_max - common_min + 1;
    if (common < 0) {
        return 0;
    } else {
        return common;
    }
}

bool Fragment::operator==(const Fragment& other) const {
    typedef boost::tuple<int, int, const std::string&> T;
    T t1(start_, stop_, sequence()->name());
    T t2(other.start_, other.stop_, other.sequence()->name());
    return t1 == t2;
}

bool Fragment::operator<(const Fragment& other) const {
    ASSERT_TRUE(!parted());
    ASSERT_TRUE(!other.parted());
    typedef boost::tuple<int, int, const std::string&> T;
    T t1(start_, stop_, sequence()->name());
    T t2(other.start_, other.stop_, other.sequence()->name());
    return t1 < t2;
}

Block::Block() {
}

BlockPtr Block::make(const Fragments& fragments) {
    ASSERT_MSG(fragments.size(), "Empty block is not allowed");
    Block* block = new Block;
    BlockPtr b(block);
    block->fragments_ = fragments;
    Fragments& ff = block->fragments_;
    std::sort(ff.begin(), ff.end());
    int n = ff.size();
    block->rows_.resize(n);
    size_t max_len = 0;
    for (int i = 0; i < n; i++) {
        const FragmentPtr& fragment = ff[i];
        std::string& row = block->rows_[i];
        row = fragment->text();
        max_len = std::max(max_len, row.length());
    }
    BOOST_FOREACH (std::string& row, block->rows_) {
        row.resize(max_len, '-');
    }
    block->length_ = max_len;
    return b;
}

BlockPtr Block::make(const Fragments& fragments,
                     const CStrings& rows) {
    ASSERT_EQ(fragments.size(), rows.size());
    ASSERT_MSG(fragments.size(), "Empty block is not allowed");
    int n = fragments.size();
    Ints indexes;
    range(indexes, n);
    std::sort(indexes.begin(), indexes.end(),
              IndexedFragmentLess(fragments));
    //
    Block* block = new Block;
    BlockPtr b(block);
    block->fragments_.resize(n);
    block->rows_.resize(n);
    for (int i = 0; i < n; i++) {
        int index = indexes[i];
        const FragmentPtr& fragment = fragments[index];
        block->fragments_[i] = fragment;
        const CString& row0 = rows[index];
        const char* row_text = row0.first;
        int row_size = row0.second;
        Buffer b(new char[row0.second]);
        int len = toAtgcnAndGap(b.get(), row_text, row_size);
        block->rows_[i].assign(b.get(), len);
#ifndef NPGE_NO_ASSERTS
        // compare with fragment text
        int len2 = toAtgcn(b.get(), row_text, row_size);
        std::string fr_str = fragment->text();
        ASSERT_EQ(len2, fr_str.size());
        ASSERT_EQ(memcmp(b.get(), fr_str.c_str(), len2), 0);
#endif
    }
    //
    block->length_ = block->rows_[0].length();
    ASSERT_GT(block->length_, 0);
    BOOST_FOREACH (const std::string& row, block->rows_) {
        ASSERT_EQ(row.length(), block->length_);
    }
    return b;
}

bool Block::operator==(const Block& other) const {
    if (size() != other.size()) {
        return false;
    }
    typedef std::map<std::string, const std::string*> Id2Text;
    Id2Text id2text;
    int n = size();
    for (int i = 0; i < n; i++) {
        const FragmentPtr& f = fragments_[i];
        const std::string& text = rows_[i];
        id2text[f->id()] = &text;
    }
    for (int i = 0; i < n; i++) {
        const FragmentPtr& f = other.fragments_[i];
        Id2Text::const_iterator it = id2text.find(f->id());
        if (it == id2text.end()) {
            return false;
        }
        const std::string& t1 = *(it->second);
        const std::string& t2 = other.rows_[i];
        if (t1 != t2) {
            return false;
        }
    }
    return true;
}

int Block::length() const {
    return length_;
}

int Block::size() const {
    return fragments_.size();
}

const Fragments& Block::fragments() const {
    return fragments_;
}

const std::string& Block::text(
        const FragmentPtr& fragment) const {
    Fragments::const_iterator it = binarySearch(
            fragments_.begin(), fragments_.end(),
            fragment);
    ASSERT_MSG(it != fragments_.end(),
               "Fragment not in block");
    int index = std::distance(fragments_.begin(), it);
    return rows_[index];
}

std::string Block::tostring() const {
    return "Block of " + TO_S(size()) + " fragments, "
           "length " + TO_S(length());
}

static int countNongaps(const char* t, int length) {
    int nongaps_before = 0;
    for (int bp = 0; bp < length; bp++) {
        if (t[bp] != '-') {
            nongaps_before += 1;
        }
    }
    return nongaps_before;
}

int Block::block2fragment(const FragmentPtr& fragment,
                          int blockpos) const {
    ASSERT_LTE(0, blockpos);
    ASSERT_LT(blockpos, length());
    const std::string& t_str = text(fragment);
    const char* t = t_str.c_str();
    if (t[blockpos] == '-') {
        return -1;
    } else {
        return countNongaps(t, blockpos);
    }
}

int Block::block2left(const FragmentPtr& fragment,
                      int blockpos) const {
    ASSERT_LTE(0, blockpos);
    ASSERT_LT(blockpos, length());
    const std::string& t_str = text(fragment);
    const char* t = t_str.c_str();
    if (t[blockpos] == '-') {
        return countNongaps(t, blockpos) - 1;
    } else {
        return countNongaps(t, blockpos);
    }
}

int Block::block2right(const FragmentPtr& fragment,
                       int blockpos) const {
    ASSERT_LTE(0, blockpos);
    ASSERT_LT(blockpos, length());
    const std::string& t_str = text(fragment);
    const char* t = t_str.c_str();
    if (t[blockpos] == '-') {
        int nongaps = countNongaps(t, blockpos);
        if (nongaps < fragment->length()) {
            return nongaps;
        } else {
            return -1;
        }
    } else {
        return countNongaps(t, blockpos);
    }
}

}
