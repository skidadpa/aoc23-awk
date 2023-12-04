#!/usr/bin/env gawk -f
BEGIN {
    FS = ""
    num_parts = 0
    DEBUG = 0
}
function check_gear(p, r, c) {
    if (r SUBSEP c in gears) {
        if (DEBUG) {
            printf(" gear(%d,%d)", r, c)
        }
        gears[r,c][p] = parts[p]["VALUE"]
    }
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
            if ($c == "*") {
                split("", gears[NR,c])
            }
        }
    }
    processing_number = 0
}
END {
    for (p in parts) {
        if (DEBUG) {
            printf("part %d (%d):", p, parts[p]["VALUE"])
        }
        check_gear(p, parts[p]["ROW"], parts[p]["START"] - 1)
        check_gear(p, parts[p]["ROW"], parts[p]["END"] + 1)
        for (c = parts[p]["START"] - 1; c <= parts[p]["END"] + 1; ++c) {
            check_gear(p, parts[p]["ROW"] - 1, c)
            check_gear(p, parts[p]["ROW"] + 1, c)
        }
        if (DEBUG) {
            printf("\n")
        }
    }
    sum = 0
    for (g in gears) {
        value = 1
        if (DEBUG) {
            printf("Gear (")
        }
        for (p in gears[g]) {
            if (DEBUG) {
                printf("%d", gears[g][p])
            }
            value *= gears[g][p]
        }
        if (DEBUG) {
            printf("): %d", value)
        }
        if (length(gears[g]) == 2) {
            sum += value
            if (DEBUG) {
                printf(" (VALID)\n")
            }
        } else if (DEBUG) {
            printf(" (INVALID)\n")
        }
    }
    print sum
}
