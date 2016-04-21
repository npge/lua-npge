/* lua-npge, Nucleotide PanGenome explorer (Lua module)
 * Copyright (C) 2014-2016 Boris Nagaev
 * See the LICENSE file for terms of use.
 */

#ifndef NPGE_MODEL_HPP_
#define NPGE_MODEL_HPP_

#include <string>
#include <vector>
#include <utility>
#include <boost/intrusive_ptr.hpp>
#include "intrusive_ref_counter.hpp"

namespace lnpge {

// strings

typedef std::pair<const char*, int> CString;
typedef std::vector<CString> CStrings;
typedef std::vector<std::string> Strings;

int complement(char* dst, const char* src, int length);

int toAtgcn(char* dst, const char* src, int length);

int toAtgcnAndGap(char* dst, const char* src, int length);

int unwindRow(char* result, const char* row, int row_size,
              const char* orig, int orig_size);

// returns if i-th column is good
bool isColumnGood(const char** rows, int nrows, int i);

// returns if i-th column is ident with gaps
bool isColumnIdentGap(const char** rows, int nrows, int i);

// returns percentage and number of good columns
double identity(const char** rows, int nrows,
                int start, int stop);

char consensusAtPos(const char** rows, int nrows, int i);

// size of dst is length. 0 byte is not required
void consensus(char* dst, const char** rows,
               int nrows, int length);

// size of dst is at least length + 2, 0 byte is not required
// returns length of result
int ShortForm_diff(char* dst, const char* consensus,
                   const char* text, int length);

const int MAX_COLUMN_SCORE = 100;

typedef std::pair<int, int> StartStop; // start, stop
typedef std::vector<StartStop> Coordinates;
typedef std::vector<int> Scores;

// if min_identity or min_length == 1, it is not applied
Scores goodColumns(const char** rows, int nrows, int length,
                   int min_identity, int min_length);
Coordinates goodSlices(const Scores& score,
                       int frame_length, int end_length,
                       int min_identity, int min_length);

// alignment

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

char* alignedRow(Aln* aln, int irow);

void alignLeft(Aln* aln);

int prefixLength(const char** rows, int nrows, int len);

bool findAnchor(int* result, int nrows,
        const char** rows, const int* lens,
        int& ANCHOR, int MIN_LENGTH, int MIN_ANCHOR);

void removePureGaps(Strings& aligned);

void refineAlignment(Strings& aligned);

// model

class Sequence;
class Fragment;
class Block;
class BlockSet;

typedef boost::intrusive_ptr<const Sequence> SequencePtr;
typedef boost::intrusive_ptr<const Fragment> FragmentPtr;
typedef boost::intrusive_ptr<const Block> BlockPtr;
typedef boost::intrusive_ptr<const BlockSet> BlockSetPtr;

typedef std::pair<FragmentPtr, FragmentPtr> TwoFragments;

typedef std::vector<SequencePtr> Sequences;
typedef std::vector<FragmentPtr> Fragments;
typedef std::vector<BlockPtr> Blocks;
typedef std::vector<BlockSetPtr> BlockSets;

class Sequence :
    public boost::intrusive_ref_counter<Sequence> {
public:
    static SequencePtr make(const std::string& name,
                            const std::string& description,
                            const char* text, int len);

    const std::string& name() const;

    const std::string& description() const;

    std::string genome() const;

    std::string chromosome() const;

    bool circular() const;

    int length() const;

    const std::string& text() const;

    std::string sub(int min, int max) const;

    std::string tostring() const;

    bool operator==(const Sequence& other) const;

private:
    std::string name_, description_, text_;

    Sequence();
};

class Fragment :
    public boost::intrusive_ref_counter<Fragment> {
public:
    static FragmentPtr make(SequencePtr sequence,
                            int start, int stop, int ori);

    const SequencePtr& sequence() const;

    int start() const;

    int stop() const;

    int ori() const;

    bool parted() const;

    int length() const;

    std::string id() const;

    std::string tostring() const;

    TwoFragments parts() const;

    std::string text() const;

    int common(const Fragment& other) const;

    bool operator==(const Fragment& other) const;

    bool operator<(const Fragment& other) const;

private:
    SequencePtr sequence_;
    int start_;
    int stop_; // (stop + 1) * ori

    Fragment();
};

int fragmentMin(const Fragment& fragment);

int fragmentMax(const Fragment& fragment);

class Block :
    public boost::intrusive_ref_counter<Block> {
public:
    static BlockPtr make(const Fragments& fragments);

    static BlockPtr make(const Fragments& fragments,
                         const CStrings& rows);

    bool operator==(const Block& other) const;

    bool operator<(const Block& other) const;

    int length() const;

    int size() const;

    const Fragments& fragments() const;

    const std::string& text(const FragmentPtr& fragment) const;

    std::string tostring() const;

    int fragment2block(const FragmentPtr& fragment,
                       int fragmentpos) const;

    int block2fragment(const FragmentPtr& fragment,
                       int blockpos) const;

    int block2left(const FragmentPtr& fragment,
                   int blockpos) const;

    int block2right(const FragmentPtr& fragment,
                    int blockpos) const;

private:
    Fragments fragments_;
    Strings rows_;
    int length_;

    Block();
};

struct SeqRecord {
    SequencePtr sequence_;
    Fragments fragments_; // original fragments or parts
    Blocks blocks_;

    Coordinates segment_tree_; // only if internal_overlaps_

    Fragments orig_fragments_; // only if same_parts_
    Blocks orig_blocks_; // only if same_parts_

    bool internal_overlaps_; // order by start != order by stop
    bool same_parts_; // equal elements in fragments_
};

typedef std::vector<SeqRecord> SeqRecords;

struct BlockRecord {
    BlockPtr block_;
    std::string name_;
};

typedef std::vector<BlockRecord> BlockRecords;

void makeSegmentTree(Coordinates& tree,
                     const Fragments& fragments);

void findOverlapping(Fragments& result,
                     const Coordinates& tree,
                     const Fragments& fragments,
                     const FragmentPtr& fragment);

class BlockSet :
    public boost::intrusive_ref_counter<BlockSet> {
public:
    static BlockSetPtr make(const Sequences& sequences,
                            const Blocks& blocks,
                            const Strings& names);

    bool sameSequences(const BlockSet& other) const;

    // 0 on success
    const char* cmp(const BlockSet& other) const;

    bool operator==(const BlockSet& other) const;

    int size() const;

    bool isPartition() const;

    const BlockPtr& blockAt(int i) const;

    const std::string& nameAt(int i) const;

    BlockPtr blockByName(const std::string& name) const;

    // searches by block value, not by pointer
    std::string nameByBlock(const BlockPtr& block) const;
    bool hasBlock(const BlockPtr& block) const;

    const Fragments& parts(const SequencePtr& sequence) const;

    const FragmentPtr& parentOrFragment(
            const FragmentPtr& f) const;

    int sequencesNumber() const;

    const SequencePtr& sequenceAt(int index) const;

    bool hasSequence(const SequencePtr& sequence) const;

    SequencePtr sequenceByName(const std::string& name) const;

    BlockPtr blockByFragment(const FragmentPtr& fragment) const;

    Blocks blocksByFragment(const FragmentPtr& fragment) const;

    Fragments overlapping(const FragmentPtr& fragment) const;

    FragmentPtr next(const FragmentPtr& fragment) const;

    FragmentPtr prev(const FragmentPtr& fragment) const;

    std::string tostring() const;

private:
    // sorted by sequence name
    SeqRecords seq_records_;

    BlockRecords block2name_;
    BlockRecords name2block_;

    Fragments parts_;
    Fragments parent_of_parts_;

    bool isPartition_;

    BlockSet();
};

}

#endif
