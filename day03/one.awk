#!/usr/bin/env gawk -f
BEGIN {
    FS = ""
    num_parts = 0
    DEBUG = 0
}
function part_valid(p) {
    if ((parts[p]["ROW"] SUBSEP (parts[p]["START"] - 1) in symbols) ||
        (parts[p]["ROW"] SUBSEP (parts[p]["END"] + 1) in symbols)) {
        return 1
    }
    for (c = parts[p]["START"] - 1; c <= parts[p]["END"] + 1; ++c) {
        if (((parts[p]["ROW"] - 1) SUBSEP c in symbols) ||
            ((parts[p]["ROW"] + 1) SUBSEP c in symbols)) {
            return 1
        }
    }
    return 0
}
{
    for (c = 1; c <= NF; ++c) {
        if ($c ~ /[[:digit:]]/) {
            if (!processing_number) {
                processing_number = 1
                ++num_parts
                parts[num_parts]["ROW"] = NR
                parts[num_parts]["START"] = c
                parts[num_parts]["VALUE"] = 0
            }
            parts[num_parts]["END"] = c
            parts[num_parts]["VALUE"] = parts[num_parts]["VALUE"] * 10 + $c
        } else {
            processing_number = 0
            if ($c != ".") {
                symbols[NR,c] = $c
            }
        }
    }
    processing_number = 0
}
END {
    sum = 0
    for (p in parts) {
        if (DEBUG) {
            printf("part %d (%d): ", p, parts[p]["VALUE"])
        }
        if (part_valid(p)) {
            sum += parts[p]["VALUE"]
            if (DEBUG) {
                print "VALID"
            }
        } else if (DEBUG) {
            print "INVALID"
        }
    }
    print sum
}
