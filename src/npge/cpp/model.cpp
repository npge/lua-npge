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
#include <set>
#include <boost/foreach.hpp>
#include <boost/scoped_array.hpp>
#include <boost/tuple/tuple.hpp>
#include <boost/tuple/tuple_comparison.hpp>
#include <boost/algorithm/string/split.hpp>
#include <boost/algorithm/string/classification.hpp>

#include "model.hpp"
#include "throw_assert.hpp"
#include "cast.hpp"

namespace lnpge {

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

struct SequenceLess {
    bool operator()(const SequencePtr& a,
                    const SequencePtr& b) const {
        return a->name() < b->name();
    }

    bool operator()(const SequencePtr& a,
                    const std::string& b) const {
        return a->name() < b;
    }

    bool operator()(const std::string& a,
                    const SequencePtr& b) const {
        return a < b->name();
    }
};

struct IndexedFragmentPtrLess {
    IndexedFragmentPtrLess(const Fragments& fragments):
        fragments_(fragments) {
    }

    bool operator()(int a, int b) const {
        return fragments_[a] < fragments_[b];
    }

    const Fragments& fragments_;
};

struct IndexedFragmentLess {
    IndexedFragmentLess(const Fragments& fragments):
        fragments_(fragments) {
    }

    bool operator()(int a, int b) const {
        return *(fragments_[a]) < *(fragments_[b]);
    }

    const Fragments& fragments_;
};

struct FragmentLess {
    bool operator()(const FragmentPtr& a,
                    const FragmentPtr& b) const {
        return *a < *b;
    }
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
    typedef boost::tuple<int, int, int, const std::string&> T;
    int self_min = std::min(start(), stop());
    int self_max = std::max(start(), stop());
    int other_min = std::min(other.start(), other.stop());
    int other_max = std::max(other.start(), other.stop());
    T t1(self_min, self_max, ori(), sequence()->name());
    T t2(other_min, other_max, other.ori(),
            other.sequence()->name());
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
              IndexedFragmentPtrLess(fragments));
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

///////

// sorted by name
static int rawSeq2index(const std::string& name,
                        const Sequences& seqs) {
    Sequences::const_iterator it = binarySearch(
            seqs.begin(), seqs.end(), name, SequenceLess());
    if (it == seqs.end()) {
        return seqs.size();
    } else {
        return std::distance(seqs.begin(), it);
    }
}

static int seq2index(const std::string& name,
                     const Sequences& seqs) {
    int index = rawSeq2index(name, seqs);
    ASSERT_MSG(index != seqs.size(),
               ("Sequence not in BlockSet: " + name).c_str());
    return index;
}

static void prepareSequences(Sequences& dst,
                             const Sequences& src) {
    dst = src;
    std::sort(dst.begin(), dst.end(), SequenceLess());
    int nseqs = src.size();
    for (int i = 1; i < nseqs; i++) {
        ASSERT_NE(dst[i - 1]->name(), dst[i]->name());
    }
}

typedef std::vector<Fragments> FMap;
typedef std::vector<Blocks> BMap;

static void collectFragments(FMap& fmap, BMap& bmap,
                             Fragments& parts,
                             Fragments& parent_of_parts,
                             const Blocks& blocks,
                             const Sequences& sequences) {
    int nseqs = sequences.size();
    fmap.resize(nseqs);
    bmap.resize(nseqs);
    BOOST_FOREACH (const BlockPtr& b, blocks) {
        BOOST_FOREACH (const FragmentPtr& f, b->fragments()) {
            const SequencePtr& seq = f->sequence();
            int i = seq2index(seq->name(), sequences);
            Fragments& flist = fmap[i];
            Blocks& blist = bmap[i];
            if (!f->parted()) {
                flist.push_back(f);
                blist.push_back(b);
            } else {
                TwoFragments two = f->parts();
                flist.push_back(two.first);
                flist.push_back(two.second);
                blist.push_back(b);
                blist.push_back(b);
                //
                parts.push_back(two.first);
                parts.push_back(two.second);
                parent_of_parts.push_back(f);
                parent_of_parts.push_back(f);
            }
        }
    }
}

static void sortFragments(FMap& fmap, BMap& bmap) {
    int nseqs = fmap.size();
    for (int i = 0; i < nseqs; i++) {
        Fragments& fragments = fmap[i];
        Blocks& blocks = bmap[i];
        int n = fragments.size();
        Ints indexes;
        range(indexes, n);
        std::sort(indexes.begin(), indexes.end(),
                  IndexedFragmentLess(fragments));
        Fragments new_fragments(n);
        Blocks new_blocks(n);
        for (int j = 0; j < n; j++) {
            int index = indexes[j];
            new_fragments[j] = fragments[index];
            new_blocks[j] = blocks[index];
        }
        fragments.swap(new_fragments);
        blocks.swap(new_blocks);
    }
}

static void sortParts(Fragments& parts, Fragments& parents) {
    int n = parts.size();
    Ints indexes;
    range(indexes, n);
    std::sort(indexes.begin(), indexes.end(),
              IndexedFragmentPtrLess(parts));
    Fragments new_parts(n);
    Fragments new_parents(n);
    for (int i = 0; i < n; i++) {
        int index = indexes[i];
        new_parts[i] = parts[index];
        new_parents[i] = parents[index];
    }
    parts.swap(new_parts);
    parents.swap(new_parents);
}

static bool testPartition(const FMap& fmap,
                          const Sequences& sequences) {
    int n = sequences.size();
    for (int i = 0; i < n; i++) {
        const SequencePtr& seq = sequences[i];
        const Fragments& fragments = fmap[i];
        int sum = 0;
        int prev_stop = -1;
        BOOST_FOREACH (const FragmentPtr& f, fragments) {
            sum += f->length();
            if (f->start() <= prev_stop) {
                // overlap
                return false;
            }
            prev_stop = f->stop();
        }
        if (sum != seq->length()) {
            return false;
        }
    }
    return true;
}

BlockSet::BlockSet() {
}

BlockSetPtr BlockSet::make(const Sequences& sequences,
                           const Blocks& blocks) {
    BlockSet* bs = new BlockSet;
    BlockSetPtr ptr(bs);
    prepareSequences(bs->sequences_, sequences);
    //
    bs->blocks_ = blocks;
    //
    collectFragments(bs->to_fragments_, bs->to_blocks_,
                     bs->parts_, bs->parent_of_parts_,
                     blocks, bs->sequences_);
    sortFragments(bs->to_fragments_, bs->to_blocks_);
    sortParts(bs->parts_, bs->parent_of_parts_);
    //
    bs->is_partition_ = testPartition(bs->to_fragments_,
            bs->sequences_);
    //
    return ptr;
}

bool BlockSet::sameSequences(const BlockSet& other) const {
    if (sequences_.size() != other.sequences_.size()) {
        return false;
    }
    int n = sequences_.size();
    for (int i = 0; i < n; i++) {
        const SequencePtr& a = sequences_[i];
        const SequencePtr& b = other.sequences_[i];
        if (a->name() != b->name()) {
            return false;
        }
    }
    return true;
}

std::pair<bool, std::string>
BlockSet::cmp(const BlockSet& other) const {
    if (!sameSequences(other)) {
        return std::make_pair(false, "sequences");
    }
    if (size() != other.size()) {
        return std::make_pair(false, "size");
    }
    int nseqs = sequences_.size();
    Blocks blocks1, blocks2;
    std::set<BlockPtr> blocks1_set, blocks2_set;
    for (int i = 0; i < nseqs; i++) {
        const Fragments& ff1 = to_fragments_[i];
        const Fragments& ff2 = other.to_fragments_[i];
        const Blocks& bb1 = to_blocks_[i];
        const Blocks& bb2 = other.to_blocks_[i];
        if (ff1.size() != ff2.size()) {
            return std::make_pair(false, "fragments");
        }
        int n = ff1.size();
        for (int j = 0; j < n; j++) {
            const FragmentPtr& f1 = ff1[j];
            const FragmentPtr& f2 = ff2[j];
            if (!(*f1 == *f2)) {
                return std::make_pair(false, "fragments");
            }
            const BlockPtr& b1 = bb1[j];
            const BlockPtr& b2 = bb2[j];
            if (blocks1_set.find(b1) == blocks1_set.end()) {
                blocks1_set.insert(b1);
                blocks1.push_back(b1);
            }
            if (blocks2_set.find(b2) == blocks2_set.end()) {
                blocks2_set.insert(b2);
                blocks2.push_back(b2);
            }
        }
    }
    if (blocks1.size() != blocks2.size()) {
        return std::make_pair(false, "blocks");
    }
    int n = blocks1.size();
    for (int i = 0; i < n; i++) {
        const BlockPtr& a = blocks1[i];
        const BlockPtr& b = blocks2[i];
        if (!(*a == *b)) {
            return std::make_pair(false, "blocks");
        }
    }
    return std::make_pair(true, "");
}

bool BlockSet::operator==(const BlockSet& other) const {
    std::pair<bool, std::string> r = cmp(other);
    return r.first;
}

int BlockSet::size() const {
    return blocks_.size();
}

bool BlockSet::isPartition() const {
    return is_partition_;
}

const Blocks& BlockSet::blocks() const {
    return blocks_;
}

const Fragments& BlockSet::parts(
        const SequencePtr& sequence) const {
    int index = seq2index(sequence->name(), sequences_);
    return to_fragments_[index];
}

const Sequences& BlockSet::sequences() const {
    return sequences_;
}

bool BlockSet::hasSequence(const SequencePtr& sequence) const {
    int index = rawSeq2index(sequence->name(), sequences_);
    return index != sequences_.size();
}

SequencePtr BlockSet::sequenceByName(
        const std::string& name) const {
    int index = rawSeq2index(name, sequences_);
    if (index != sequences_.size()) {
        return sequences_[index];
    } else {
        return SequencePtr();
    }
}

BlockPtr BlockSet::blockByFragment(
        const FragmentPtr& fragment) const {
    if (fragment->parted()) {
        TwoFragments two = fragment->parts();
        return blockByFragment(two.first);
    }
    const SequencePtr& sequence = fragment->sequence();
    int index = rawSeq2index(sequence->name(), sequences_);
    if (index == sequences_.size()) {
        return BlockPtr();
    }
    const Fragments& fragments = to_fragments_[index];
    Fragments::const_iterator it = binarySearch(
            fragments.begin(), fragments.end(),
            fragment, FragmentLess());
    if (it == fragments.end()) {
        return BlockPtr();
    }
    while (*it != fragment) {
        // fragments are equal but different instances
        it++;
        if (it == fragments.end() || !(*(*it) == *fragment)) {
            return BlockPtr();
        }
    }
    int index2 = std::distance(fragments.begin(), it);
    return to_blocks_[index][index2];
}

const FragmentPtr& BlockSet::parentOrFragment(
        const FragmentPtr& f) const {
    Fragments::const_iterator it = binarySearch(
            parts_.begin(), parts_.end(), f);
    if (it == parts_.end()) {
        return f;
    } else {
        int index = std::distance(parts_.begin(), it);
        return parent_of_parts_[index];
    }
}

void sortAndUnique(const BlockSet* self, Fragments& ff) {
    BOOST_FOREACH (FragmentPtr& f, ff) {
        f = self->parentOrFragment(f);
    }
    std::sort(ff.begin(), ff.end());
    ff.erase(std::unique(ff.begin(), ff.end()), ff.end());
}

Fragments BlockSet::overlapping(
        const FragmentPtr& fragment) const {
    if (fragment->parted()) {
        TwoFragments two = fragment->parts();
        Fragments o1 = overlapping(two.first);
        Fragments o2 = overlapping(two.second);
        Fragments result;
        BOOST_FOREACH (const FragmentPtr& f, o1) {
            result.push_back(f);
        }
        BOOST_FOREACH (const FragmentPtr& f, o2) {
            result.push_back(f);
        }
        sortAndUnique(this, result);
        return result;
    }
    const SequencePtr& sequence = fragment->sequence();
    int index = rawSeq2index(sequence->name(), sequences_);
    if (index == sequences_.size()) {
        return Fragments();
    }
    const Fragments& fragments = to_fragments_[index];
    const Fragments::const_iterator it = std::upper_bound(
            fragments.begin(), fragments.end(),
            fragment, FragmentLess());
    int index2;
    if (it == fragments.end()) {
        index2 = fragments.size();
    } else {
        index2 = std::distance(fragments.begin(), it);
    }
    Fragments result;
    for (int j = index2; j < fragments.size(); j++) {
        const FragmentPtr& f = fragments[j];
        if (f->common(*fragment)) {
            result.push_back(f);
        } else {
            break;
        }
    }
    for (int j = index2 - 1; j >= 0; j--) {
        const FragmentPtr& f = fragments[j];
        if (f->common(*fragment)) {
            result.push_back(f);
        } else {
            break;
        }
    }
    sortAndUnique(this, result);
    return result;
}

FragmentPtr BlockSet::next(const FragmentPtr& fragment) const {
    const SequencePtr& sequence = fragment->sequence();
    if (fragment->parted()) {
        TwoFragments two = fragment->parts();
        FragmentPtr part = two.first;
        if (*two.second < *two.first) {
            part = two.second;
        }
        return next(part);
    }
    int index = rawSeq2index(sequence->name(), sequences_);
    if (index == sequences_.size()) {
        return FragmentPtr();
    }
    ASSERT_TRUE(sequence == sequences_[index]);
    const Fragments& fragments = to_fragments_[index];
    Fragments::const_iterator it = binarySearch(
            fragments.begin(), fragments.end(),
            fragment, FragmentLess());
    if (it == fragments.end()) {
        return FragmentPtr();
    }
    it++;
    if (it == fragments.end()) {
        if (!sequence->circular()) {
            return FragmentPtr();
        }
        it = fragments.begin();
    }
    const FragmentPtr& f = *it;
    return parentOrFragment(f);
}

FragmentPtr BlockSet::prev(const FragmentPtr& fragment) const {
    const SequencePtr& sequence = fragment->sequence();
    if (fragment->parted()) {
        TwoFragments two = fragment->parts();
        FragmentPtr part = two.first;
        if (*two.first < *two.second) {
            part = two.second;
        }
        return prev(part);
    }
    int index = rawSeq2index(sequence->name(), sequences_);
    if (index == sequences_.size()) {
        return FragmentPtr();
    }
    ASSERT_TRUE(sequence == sequences_[index]);
    const Fragments& fragments = to_fragments_[index];
    Fragments::const_iterator it = binarySearch(
            fragments.begin(), fragments.end(),
            fragment, FragmentLess());
    if (it == fragments.end()) {
        return FragmentPtr();
    }
    if (it == fragments.begin()) {
        if (!sequence->circular()) {
            return FragmentPtr();
        }
        it = fragments.end();
    }
    it--;
    const FragmentPtr& f = *it;
    return parentOrFragment(f);
}

std::string BlockSet::tostring() const {
    std::string text = "BlockSet of " +
        TO_S(sequences().size()) + " sequences and " +
        TO_S(size()) + " blocks";
    if (isPartition()) {
        text += " (partition)";
    }
    return text;
}

}
