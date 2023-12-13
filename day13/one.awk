#!/usr/bin/env gawk -f
function reset_map() {
    nrows = ncols = 0
    split("", rows)
    split("", cols)
}
function reflected(arr, size, i,   j) {
    for (j = 1; (i + j <= size) && (i - j >= 0); ++j) {
        if (DEBUG > 2) {
            print "COMPARING", arr[i + j], "to", arr[i + 1 - j]
        }
        if (arr[i + j] != arr[i + 1 - j]) {
            return 0
        }
    }
    return 1
}
function map_score(   score, i) {
    score = 0
    for (i = 1; i < nrows; ++i) {
        if (reflected(rows, nrows, i)) {
            if (DEBUG > 1) {
                print "MIRRORS AT ROW", i
            }
            score += i * 100
        }
    }
    for (i = 1; i < ncols; ++i) {
        if (reflected(cols, ncols, i)) {
            if (DEBUG > 1) {
                print "MIRRORS AT COLUMN", i
            }
            score += i
        }
    }
    if (DEBUG) {
        print "SCORES", score
    }
    return score
}
BEGIN {
    DEBUG = 0
    sum = 0
    reset_map()
    FS = ""
}
/^[.#]+$/ {
    if (!ncols) {
        ncols = NF
    } else if (ncols != NF) {
        print "DATA ERROR, current solution only support rectangular maps"
        exit _exit=1
    }
    rows[++nrows] = $0
    for (i = 1; i <= NF; ++i) {
        cols[i] = cols[i] $i
    }
    if (DEBUG) {
        print
    }
    next
}
/^$/ {
    sum += map_score()
    reset_map()
    next
}
{
    print "DATA ERROR, unrecognized line", $0
    exit _exit=1
}
END {
    if (_exit) {
        exit _exit
    }
    sum += map_score()
    print sum
}
