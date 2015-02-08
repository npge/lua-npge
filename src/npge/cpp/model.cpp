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

Sequence::Sequence() {
}

SequencePtr Sequence::make(const std::string& name,
                           const std::string& description,
                           const char* text, int len) {
    Buffer b(new char[len]);
    int b_len = toAtgcn(b.get(), text, len);
    ASSERT_MSG(name.length(), "No unknown sequences allowed");
    ASSERT_MSG(b_len, "No empty sequences allowed");
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
    FragmentPtr fragment(new Fragment);
    fragment->sequence_ = sequence;
    fragment->start_ = start;
    fragment->stop_ = (stop + 1) * ori;
    if (!sequence->circular()) {
        ASSERT_MSG(!fragment->parted(), "Found parted "
                   "fragment on linear sequence");
    }
    return fragment;
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

}
