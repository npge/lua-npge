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
#include <boost/scoped_array.hpp>
#include <boost/algorithm/string/split.hpp>
#include <boost/algorithm/string/classification.hpp>

#include "model.hpp"
#include "throw_assert.hpp"
#include "cast.hpp"

namespace npge {

typedef boost::scoped_array<char> Buffer;

Sequence::Sequence() {
}

SequencePtr Sequence::make(const std::string& name,
                           const std::string& description,
                           const char* text, int len) {
    Buffer b(new char[len]);
    int b_len = toAtgcn(b.get(), text, len);
    ASSERT_GT(name.length(), 0);
    ASSERT_GT(b_len, 0);
    SequencePtr seq(new Sequence);
    seq->text_.assign(b.get(), b_len);
    seq->name_ = name;
    seq->description_ = description;
    return seq;
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

}
