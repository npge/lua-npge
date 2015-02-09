/*
 * NPG-explorer, Nucleotide PanGenome explorer
 * Copyright (C) 2012-2015 Boris Nagaev
 *
 * See the LICENSE file for terms of use.
 */

#include <cstdlib>
#include <cstring>
#include <stdexcept>
#include <sstream>
#include <iostream>

#include "throw_assert.hpp"

namespace lnpge {

#define SRC_PATTERN "src/"

const char* reduce_path(const char* file) {
    const char* subpath = strstr(file, SRC_PATTERN);
    return subpath ? (subpath + strlen(SRC_PATTERN)) : file;
}

void assertion_failed_msg(char const* expr, char const* msg,
                          char const* function,
                          char const* file, long line) {
    std::stringstream err;
    err << reduce_path(file) << ":" << line;
    err << ": " << function << ": ";
    err << "Assertation `" << expr << "' failed.";
    err << std::endl;
    err << "Error message `" << msg << "'.";
    throw std::logic_error(err.str());
}

}
