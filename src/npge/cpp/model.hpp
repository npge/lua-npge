/*
 * NPG-explorer, Nucleotide PanGenome explorer
 * Copyright (C) 2012-2015 Boris Nagaev
 *
 * See the LICENSE file for terms of use.
 */

#ifndef NPGE_MODEL_HPP_
#define NPGE_MODEL_HPP_

#include <string>
#include <vector>
#include <utility>
#include <boost/intrusive_ptr.hpp>
#include "intrusive_ref_counter.hpp"

namespace npge {

int complement(char* dst, const char* src, int length);

int toAtgcn(char* dst, const char* src, int length);

int toAtgcnAndGap(char* dst, const char* src, int length);

class Sequence;
class Fragment;

typedef boost::intrusive_ptr<Sequence> SequencePtr;

typedef std::vector<std::string> Strings;
typedef std::vector<SequencePtr> Sequences;
typedef std::vector<Fragment> Fragments;

typedef std::pair<Fragment, Fragment> TwoFragments;

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

class Fragment {
public:
    static Fragment make(SequencePtr sequence,
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
};

}

#endif
