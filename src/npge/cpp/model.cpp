/* lua-npge, Nucleotide PanGenome explorer (Lua module)
 * Copyright (C) 2014-2015 Boris Nagaev
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

#include "npge.hpp"
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
    if (it != end && v < *it) {
        it = end;
    }
    return it;
}

struct SeqRecordLess {
    bool operator()(const SeqRecord& a,
                    const SeqRecord& b) const {
        return a.sequence_->name() < b.sequence_->name();
    }

    bool operator()(const SeqRecord& a,
                    const std::string& b) const {
        return a.sequence_->name() < b;
    }

    bool operator()(const std::string& a,
                    const SeqRecord& b) const {
        return a < b.sequence_->name();
    }
};

struct BlockRecordBlockLess {
    bool operator()(const BlockRecord& a,
                    const BlockRecord& b) const {
        return *(b.block_) < *(a.block_);
    }

    bool operator()(const BlockRecord& a,
                    const BlockPtr& b) const {
        return *b < *(a.block_);
    }

    bool operator()(const BlockPtr& a,
                    const BlockRecord& b) const {
        return *(b.block_) < *a;
    }
};

struct BlockRecordNameLess {
    bool operator()(const BlockRecord& a,
                    const BlockRecord& b) const {
        return a.name_ < b.name_;
    }

    bool operator()(const BlockRecord& a,
                    const std::string& b) const {
        return a.name_ < b;
    }

    bool operator()(const std::string& a,
                    const BlockRecord& b) const {
        return a < b.name_;
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

struct IndexedFragmentBlockLess {
    IndexedFragmentBlockLess(const Fragments& fragments,
                             const Blocks& blocks):
        fragments_(fragments), blocks_(blocks) {
    }

    bool operator()(int a, int b) const {
        typedef const Fragment& A;
        typedef const Block& B;
        typedef boost::tuple<A, B> T;
        T ta(*(fragments_[a]), *(blocks_[a]));
        T tb(*(fragments_[b]), *(blocks_[b]));
        return ta < tb;
    }

    const Fragments& fragments_;
    const Blocks& blocks_;
};

struct IndexedFragmentTextLess {
    IndexedFragmentTextLess(const Fragments& fragments,
                            const Strings& texts):
        fragments_(fragments), texts_(texts) {
    }

    bool operator()(int a, int b) const {
        typedef const Fragment& A;
        typedef const std::string& B;
        typedef boost::tuple<A, B> T;
        T ta(*(fragments_[a]), texts_[a]);
        T tb(*(fragments_[b]), texts_[b]);
        return ta < tb;
    }

    const Fragments& fragments_;
    const Strings& texts_;
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
        int min = fragmentMin(*this);
        int max = fragmentMax(*this);
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
    if (sequence()->name() != other.sequence()->name()) {
        return 0;
    }
    if (parted()) {
        TwoFragments two = parts();
        return two.first->common(other) +
               two.second->common(other);
    }
    if (other.parted()) {
        TwoFragments two = other.parts();
        return common(*two.first) + common(*two.second);
    }
    int self_min = fragmentMin(*this);
    int self_max = fragmentMax(*this);
    int other_min = fragmentMin(other);
    int other_max = fragmentMax(other);
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
    typedef boost::tuple<const std::string&, int, int, int> T;
    int self_min = fragmentMin(*this);
    int self_max = fragmentMax(*this);
    int other_min = fragmentMin(other);
    int other_max = fragmentMax(other);
    T t1(sequence()->name(), self_min, self_max, ori());
    T t2(other.sequence()->name(),
            other_min, other_max, other.ori());
    return t1 < t2;
}

int fragmentMin(const Fragment& fragment) {
    return std::min(fragment.start(), fragment.stop());
}

int fragmentMax(const Fragment& fragment) {
    return std::max(fragment.start(), fragment.stop());
}

Block::Block() {
}

BlockPtr Block::make(const Fragments& fragments) {
    ASSERT_MSG(fragments.size(), "Empty block is not allowed");
    Block* block = new Block;
    BlockPtr b(block);
    block->fragments_ = fragments;
    Fragments& ff = block->fragments_;
    std::sort(ff.begin(), ff.end(), FragmentLess());
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
                     const CStrings& rows0) {
    ASSERT_EQ(fragments.size(), rows0.size());
    ASSERT_MSG(fragments.size(), "Empty block is not allowed");
    int n = fragments.size();
    // make rows
    Strings rows(n);
    for (int i = 0; i < n; i++) {
        const CString& row0 = rows0[i];
        const char* row_text = row0.first;
        int row_size = row0.second;
        Buffer b(new char[row0.second]);
        int len = toAtgcnAndGap(b.get(), row_text, row_size);
        rows[i].assign(b.get(), len);
#ifndef NPGE_NO_ASSERTS
        // compare with fragment text
        const FragmentPtr& fragment = fragments[i];
        int len2 = toAtgcn(b.get(), row_text, row_size);
        std::string fr_str = fragment->text();
        ASSERT_EQ(len2, fr_str.size());
        ASSERT_EQ(memcmp(b.get(), fr_str.c_str(), len2), 0);
#endif
    }
    // sort
    Ints indexes;
    range(indexes, n);
    std::sort(indexes.begin(), indexes.end(),
              IndexedFragmentTextLess(fragments, rows));
    // assign
    Block* block = new Block;
    BlockPtr b(block);
    block->fragments_.resize(n);
    block->rows_.resize(n);
    for (int i = 0; i < n; i++) {
        int index = indexes[i];
        const FragmentPtr& fragment = fragments[index];
        block->fragments_[i] = fragment;
        block->rows_[i].swap(rows[index]);
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
    if (size() != other.size() || length() != other.length()) {
        return false;
    }
    int n = size();
    for (int i = 0; i < n; i++) {
        const FragmentPtr& f1 = fragments_[i];
        const FragmentPtr& f2 = other.fragments_[i];
        const std::string& t1 = rows_[i];
        const std::string& t2 = other.rows_[i];
        if (!(*f1 == *f2) || t1 != t2) {
            return false;
        }
    }
    return true;
}

bool Block::operator<(const Block& other) const {
    typedef boost::tuple<int, int> T;
    T b1(size(), length());
    T b2(other.size(), other.length());
    if (b1 < b2) {
        return true;
    }
    if (b1 > b2) {
        return false;
    }
    int n = size();
    for (int i = 0; i < n; i++) {
        const FragmentPtr& f1 = fragments_[i];
        const FragmentPtr& f2 = other.fragments_[i];
        const std::string& r1 = rows_[i];
        const std::string& r2 = other.rows_[i];
        typedef const Fragment& A;
        typedef const std::string& B;
        typedef boost::tuple<A, B> T;
        T t1(*f1, r1);
        T t2(*f2, r2);
        if (t1 < t2) {
            return true;
        }
        if (t2 < t1) {
            return false;
        }
    }
    return false; // equal
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
            fragment, FragmentLess());
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

typedef SeqRecords::iterator Sit;
typedef SeqRecords::const_iterator CSit;

static Sit rawFindSeq(const std::string& name,
                      SeqRecords& seq_records) {
    return binarySearch(seq_records.begin(), seq_records.end(),
                        name, SeqRecordLess());
}

static CSit rawFindSeq(const std::string& name,
                       const SeqRecords& seq_records) {
    return binarySearch(seq_records.begin(), seq_records.end(),
                        name, SeqRecordLess());
}

static Sit findSeq(const std::string& name,
                   SeqRecords& seq_records) {
    Sit it = rawFindSeq(name, seq_records);
    ASSERT_MSG(it != seq_records.end(),
               ("Sequence not in BlockSet: " + name).c_str());
    return it;
}

static CSit findSeq(const std::string& name,
                    const SeqRecords& seq_records) {
    CSit it = rawFindSeq(name, seq_records);
    ASSERT_MSG(it != seq_records.end(),
               ("Sequence not in BlockSet: " + name).c_str());
    return it;
}

static void prepareSequences(SeqRecords& dst,
                             const Sequences& src) {
    int nseqs = src.size();
    dst.reserve(nseqs);
    BOOST_FOREACH (const SequencePtr& seq, src) {
        SeqRecord record;
        record.sequence_ = seq;
        dst.push_back(record);
    }
    std::sort(dst.begin(), dst.end(), SeqRecordLess());
    for (int i = 1; i < nseqs; i++) {
        ASSERT_LT(dst[i - 1].sequence_->name(),
                  dst[i].sequence_->name());
    }
}

static void collectFragments(SeqRecords& seq_records,
                             const BlockRecords& records,
                             Fragments& parts,
                             Fragments& parent_of_parts) {
    BOOST_FOREACH (const BlockRecord& br, records) {
        const BlockPtr& b = br.block_;
        BOOST_FOREACH (const FragmentPtr& f, b->fragments()) {
            const SequencePtr& seq = f->sequence();
            Sit it = findSeq(seq->name(), seq_records);
            Fragments& flist = it->fragments_;
            Blocks& blist = it->blocks_;
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

static void sortFragments(SeqRecords& seq_records) {
    BOOST_FOREACH (SeqRecord& seq_record, seq_records) {
        Fragments& fragments = seq_record.fragments_;
        Blocks& blocks = seq_record.blocks_;
        int n = fragments.size();
        Ints indexes;
        range(indexes, n);
        std::sort(indexes.begin(), indexes.end(),
                  IndexedFragmentBlockLess(fragments, blocks));
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

static void findInternalOverlaps(SeqRecords& seq_records) {
    BOOST_FOREACH (SeqRecord& seq_record, seq_records) {
        seq_record.internal_overlaps_ = false;
        Fragments& fragments = seq_record.fragments_;
        int n = fragments.size();
        for (int j = 1; j < n; j++) {
            const FragmentPtr& prev = fragments[j - 1];
            const FragmentPtr& curr = fragments[j];
            int prev_max = fragmentMax(*prev);
            int curr_max = fragmentMax(*curr);
            if (prev_max >= curr_max) {
                seq_record.internal_overlaps_ = true;
                break;
            }
        }
    }
}

static void makeSegmentTrees(SeqRecords& seq_records) {
    BOOST_FOREACH (SeqRecord& seq_record, seq_records) {
        if (!seq_record.internal_overlaps_) {
            continue;
        }
        const Fragments& fragments = seq_record.fragments_;
        Coordinates& segment_tree = seq_record.segment_tree_;
        makeSegmentTree(segment_tree, fragments);
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

static bool testPartition(const SeqRecords& seq_records) {
    BOOST_FOREACH (const SeqRecord& seq_record, seq_records) {
        const SequencePtr& seq = seq_record.sequence_;
        const Fragments& fragments = seq_record.fragments_;
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
                           const Blocks& blocks,
                           const Strings& names) {
    BlockSet* bs = new BlockSet;
    BlockSetPtr ptr(bs);
    prepareSequences(bs->seq_records_, sequences);
    //
    bs->block2name_.resize(blocks.size());
    for (int i = 0; i < blocks.size(); i++) {
        bs->block2name_[i].block_ = blocks[i];
        bs->block2name_[i].name_ = names[i];
    }
    bs->name2block_ = bs->block2name_;
    std::sort(bs->block2name_.begin(), bs->block2name_.end(),
              BlockRecordBlockLess());
    std::sort(bs->name2block_.begin(), bs->name2block_.end(),
              BlockRecordNameLess());
    for (int i = 1; i < bs->name2block_.size(); i++) {
        ASSERT_LT(bs->name2block_[i - 1].name_,
                  bs->name2block_[i].name_);
    }
    //
    collectFragments(bs->seq_records_, bs->block2name_,
                     bs->parts_, bs->parent_of_parts_);
    sortFragments(bs->seq_records_);
    findInternalOverlaps(bs->seq_records_);
    makeSegmentTrees(bs->seq_records_);
    sortParts(bs->parts_, bs->parent_of_parts_);
    //
    bs->isPartition_ = testPartition(bs->seq_records_);
    //
    return ptr;
}

bool BlockSet::sameSequences(const BlockSet& other) const {
    if (seq_records_.size() != other.seq_records_.size()) {
        return false;
    }
    int n = seq_records_.size();
    for (int i = 0; i < n; i++) {
        const SequencePtr& a = seq_records_[i].sequence_;
        const SequencePtr& b = other.seq_records_[i].sequence_;
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
    int nseqs = seq_records_.size();
    Blocks blocks1, blocks2;
    std::set<BlockPtr> blocks1_set, blocks2_set;
    for (int i = 0; i < nseqs; i++) {
        const SeqRecord& sr1 = seq_records_[i];
        const SeqRecord& sr2 = other.seq_records_[i];
        const Fragments& ff1 = sr1.fragments_;
        const Fragments& ff2 = sr2.fragments_;
        const Blocks& bb1 = sr1.blocks_;
        const Blocks& bb2 = sr2.blocks_;
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
    // numbers of blocks which has been checked to be equal
    ASSERT_EQ(blocks1.size(), blocks2.size());
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
    return block2name_.size();
}

bool BlockSet::isPartition() const {
    return isPartition_;
}

const BlockPtr& BlockSet::blockAt(int i) const {
    return block2name_[i].block_;
}

const std::string& BlockSet::nameAt(int i) const {
    return block2name_[i].name_;
}

BlockPtr BlockSet::blockByName(const std::string& n) const {
    typedef BlockRecords::const_iterator It;
    It it = binarySearch(name2block_.begin(),
                         name2block_.end(),
                         n, BlockRecordNameLess());
    if (it != name2block_.end()) {
        return it->block_;
    } else {
        return BlockPtr();
    }
}

std::string BlockSet::nameByBlock(const BlockPtr& b) const {
    typedef BlockRecords::const_iterator It;
    It it = binarySearch(block2name_.begin(),
                         block2name_.end(),
                         b, BlockRecordBlockLess());
    if (it != block2name_.end()) {
        return it->name_;
    } else {
        return "";
    }
}

const Fragments& BlockSet::parts(
        const SequencePtr& sequence) const {
    CSit it = findSeq(sequence->name(), seq_records_);
    return it->fragments_;
}

int BlockSet::sequencesNumber() const {
    return seq_records_.size();
}

const SequencePtr& BlockSet::sequenceAt(int index) const {
    return seq_records_[index].sequence_;
}

bool BlockSet::hasSequence(const SequencePtr& sequence) const {
    CSit it = rawFindSeq(sequence->name(), seq_records_);
    return it != seq_records_.end();
}

SequencePtr BlockSet::sequenceByName(
        const std::string& name) const {
    CSit it = rawFindSeq(name, seq_records_);
    if (it != seq_records_.end()) {
        return it->sequence_;
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
    CSit sit = rawFindSeq(sequence->name(), seq_records_);
    if (sit == seq_records_.end()) {
        return BlockPtr();
    }
    const Fragments& fragments = sit->fragments_;
    Fragments::const_iterator it = binarySearch(
            fragments.begin(), fragments.end(),
            fragment, FragmentLess());
    if (it == fragments.end()) {
        return BlockPtr();
    }
    if (parentOrFragment(*it) == *it) {
        // found fragment is not parted
        // TODO this is good example why no equal
        // fragments must be allowed in block and in blockset
        while (*it != fragment) {
            // fragments are equal but different instances
            it++;
            if (it == fragments.end() ||
                    !(*(*it) == *fragment)) {
                return BlockPtr();
            }
        }
    }
    int index2 = std::distance(fragments.begin(), it);
    return sit->blocks_[index2];
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
    CSit sit = rawFindSeq(sequence->name(), seq_records_);
    if (sit == seq_records_.end()) {
        return Fragments();
    }
    const Fragments& fragments = sit->fragments_;
    if (fragments.empty()) {
        return Fragments();
    }
    if (sit->internal_overlaps_) {
        // use segment tree
        Fragments result;
        const Coordinates& segment_tree = sit->segment_tree_;
        findOverlapping(result, segment_tree,
                        fragments, fragment);
        sortAndUnique(this, result);
        return result;
    }
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
    CSit sit = findSeq(sequence->name(), seq_records_);
    const Fragments& fragments = sit->fragments_;
    Fragments::const_iterator it = binarySearch(
            fragments.begin(), fragments.end(),
            fragment, FragmentLess());
    ASSERT_MSG(it != fragments.end(), "No such fragment");
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
    CSit sit = findSeq(sequence->name(), seq_records_);
    const Fragments& fragments = sit->fragments_;
    Fragments::const_iterator it = binarySearch(
            fragments.begin(), fragments.end(),
            fragment, FragmentLess());
    ASSERT_MSG(it != fragments.end(), "No such fragment");
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
        TO_S(seq_records_.size()) + " sequences and " +
        TO_S(size()) + " blocks";
    if (isPartition()) {
        text += " (partition)";
    }
    return text;
}

}
