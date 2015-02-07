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

typedef boost::intrusive_ptr<Sequence> SequencePtr;

typedef std::vector<std::string> Strings;

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

    bool operator!=(const Sequence& other) const;

private:
    std::string name_, description_, text_;

    Sequence();
};

}

#endif
