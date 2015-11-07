#!/usr/bin/python

import copy
import os
import os.path
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
                "type": fields[0],
                "orig_type": fields[0],
                "length": int(fields[1]),
            }
            if region["type"] == "+":
                region["good_length"] = region["length"]
            else:
                region["good_length"] = 0
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
        good_between = [region["good_length"] for region in regions_between if region["type"] == '+']
        length_between = [region["length"] for region in regions_between]
        good_all = sum(good_between) + 2 * frame
        length_all = sum(length_between) + 2 * frame
        return  float(good_all) / float(length_all) >= min_identity
    for prev_good, next_good in zip(long_good_region_ids, long_good_region_ids[1:]):
        regions_between = [regions[i] for i in range(prev_good + 1, next_good)]
        change_to_good = is_good_group(regions_between)
        for region in regions_between:
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
            prev["good_length"] += region["good_length"]
        else:
            prev = copy.copy(region)
            # orig_type = orig_type of first block
            joined_regions.append(prev)
    return joined_regions

def print_regions(regions, g, print_orig_type):
    for region in regions:
        mut = region["length"] - region["good_length"]
        if print_orig_type:
            g.write("%s\t%d\t%s\t%d\n" % (region["type"], region["length"], region["orig_type"], mut))
        else:
            g.write("%s\t%d\t%d\n" % (region["type"], region["length"], mut))

if __name__ == '__main__':
    min_length = int(sys.argv[1])
    min_identity = float(sys.argv[2])
    # -1 because mutation is not counted
    frame = max(3, int(round(1.0 / (1.0 - min_identity) - 1)))
    step = int(sys.argv[3])
    infile = sys.argv[4]
    f = open(infile)
    for x in f:
        if len(x.strip()) == 0:
            continue
        h = open(x.strip())
        regions0 = read_regions(h)
        regions1 = join_regions(regions0, min_identity, min_length, frame)
        dir = "step%d" % step
        try:
            os.mkdir(dir)
        except:
            pass
        fname = os.path.join(dir, x.strip())
        g = open(fname, 'w')
        if step == 1:
            print_regions(regions1, g, print_orig_type=True)
        elif step == 2:
            regions2 = fold(regions1)
            print_regions(regions2, g, print_orig_type=False)
        elif step == 3:
            regions2 = fold(regions1)
            regions3 = join_regions(regions2, min_identity, min_length, frame=min_length)
            print_regions(regions3, g, print_orig_type=True)
        elif step == 4:
            regions2 = fold(regions1)
            regions3 = join_regions(regions2, min_identity, min_length, frame=min_length)
            regions4 = fold(regions3)
            print_regions(regions4, g, print_orig_type=False)
        g.close()
        h.close()
