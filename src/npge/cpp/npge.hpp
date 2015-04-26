/* lua-npge, Nucleotide PanGenome explorer (Lua module)
 * Copyright (C) 2014-2015 Boris Nagaev
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

int complement(char* dst, const char* src, int length);

int toAtgcn(char* dst, const char* src, int length);

int toAtgcnAndGap(char* dst, const char* src, int length);

int unwindRow(char* result, const char* row, int row_size,
              const char* orig, int orig_size);

// returns if i-th column is good
bool isColumnGood(const char** rows, int nrows, int i);

// returns percentage and number of good columns
double identity(const char** rows, int nrows,
                int start, int stop);

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

bool findAnchor(int* result, int nrows, const char** rows,
        const int* lens, int ANCHOR, int MIN_LENGTH);

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
typedef std::pair<const char*, int> CString;

typedef std::vector<CString> CStrings;
typedef std::vector<std::string> Strings;
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

class BlockSet :
    public boost::intrusive_ref_counter<BlockSet> {
public:
    static BlockSetPtr make(const Sequences& sequences,
                            const Blocks& blocks);

    bool sameSequences(const BlockSet& other) const;

    std::pair<bool, std::string>
    cmp(const BlockSet& other) const;

    bool operator==(const BlockSet& other) const;

    int size() const;

    bool isPartition() const;

    const Blocks& blocks() const;

    const Fragments& parts(const SequencePtr& sequence) const;

    const FragmentPtr& parentOrFragment(
            const FragmentPtr& f) const;

    const Sequences& sequences() const;

    bool hasSequence(const SequencePtr& sequence) const;

    SequencePtr sequenceByName(const std::string& name) const;

    BlockPtr blockByFragment(const FragmentPtr& fragment) const;

    Fragments overlapping(const FragmentPtr& fragment) const;

    FragmentPtr next(const FragmentPtr& fragment) const;

    FragmentPtr prev(const FragmentPtr& fragment) const;

    std::string tostring() const;

private:
    Sequences sequences_;
    std::vector<Fragments> to_fragments_;
    std::vector<Blocks> to_blocks_;

    Blocks blocks_;

    Fragments parts_;
    Fragments parent_of_parts_;

    bool isPartition_;

    BlockSet();
};

}

#endif
