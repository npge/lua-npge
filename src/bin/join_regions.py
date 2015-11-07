#!/usr/bin/python

import copy
import sys

# TODO
# bad region >= MIN_LENGTH  ->  mark as bad
# for remaining bad regions check neighbours (how?)
# first and last positions ??

def read_regions(input_file):
    regions = []
    for line in input_file:
        fields = line.split()
        if len(fields) >= 2 and fields[0] in '+-':
            region = {
                "length": int(fields[1]),
                "type": fields[0],
            }
            regions.append(region)
    return regions

def join_regions(regions, min_identity, min_length, frame):
    regions = copy.deepcopy(regions)
    long_good_region_ids = []
    for i, region in enumerate(regions):
        if region["length"] >= frame and region["type"] == '+':
            long_good_region_ids.append(i)
    def is_good_group(regions_between):
        for region in regions_between:
            if region["type"] == '-' and region["length"] >= frame:
                return False
        good_between = [region["length"] for region in regions_between if region["type"] == '+']
        length_between = [region["length"] for region in regions_between]
        good_all = sum(good_between) + 2 * frame
        length_all = sum(length_between) + 2 * frame
        return  float(good_all) / float(length_all) >= min_identity
    for prev_good, next_good in zip(long_good_region_ids, long_good_region_ids[1:]):
        regions_between = [regions[i] for i in range(prev_good + 1, next_good)]
        change_to_good = is_good_group(regions_between)
        for region in regions_between:
            region["orig_type"] = region["type"]
            if change_to_good:
                region["type"] = '+'
            else:
                region["type"] = '-'
    return regions

def fold(regions):
    joined_regions = []
    prev = None
    for region in regions:
        if prev and region["type"] == prev["type"]:
            prev["length"] += region["length"]
        else:
            prev = copy.copy(region)
            prev["good_length"] = 0
            joined_regions.append(prev)
        orig_type = region["type"]
        if "orig_type" in region:
            orig_type = region["orig_type"]
        if orig_type == '+':
            prev["good_length"] += region["length"]
    return joined_regions

def print_joined(joined_regions, regions, g):
    assert len(joined_regions) == len(regions)
    for joined_region, region in zip(joined_regions, regions):
        assert joined_region["length"] == region["length"]
        g.write("%s\t%d\t%s\n" % (region["type"], region["length"], joined_region["type"]))

def print_regions(regions, g):
    for region in regions:
        if "good_length" in region:
            mut = region["length"] - region["good_length"]
            g.write("%s\t%d\t%d\n" % (region["type"], region["length"], mut))
        else:
            g.write("%s\t%d\n" % (region["type"], region["length"]))

_dir = "step1/"

if __name__ == '__main__':
    min_length = int(sys.argv[1])
    min_identity = float(sys.argv[2])
    # -1 because mutation is not counted
    frame = max(3, int(round(1.0 / (1.0 - min_identity) - 1)))
    full = int(sys.argv[3])
    infile = sys.argv[4]
    f = open(infile)
    for x in f:
        if len(x.strip()) == 0:
            continue
        h = open(x.strip())
        regions = read_regions(h)
        joined_regions = join_regions(regions, min_identity, min_length, frame)
        g = open(_dir + x.strip(),"w")
        if full:
            print_joined(joined_regions, regions, g)
        else:
            joined_regions = fold(joined_regions)
            print_regions(joined_regions, g)
        g.close()
        h.close()
