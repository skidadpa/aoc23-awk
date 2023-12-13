#!/usr/bin/env gawk -f
function reset_map() {
    nrows = ncols = 0
    split("", rows)
    split("", cols)
}
function reflected(arr, size, i,   j, k, s1, s2, nswaps) {
    nswaps = 0
    for (j = 1; (i + j <= size) && (i - j >= 0); ++j) {
        s1 = arr[i + j]
        s2 = arr[i + 1 - j]
        if (DEBUG > 2) {
            print "COMPARING", s1, "to", s2
        }
        if (s1 != s2) {
            for (k = 1; k <= length(s1); ++k) {
                if (substr(s1, k, 1) != substr(s2, k, 1)) {
                    if (++nswaps > 1) {
                        break
                    }
                }
            }
            if (nswaps > 1) {
                break
            }
        }
    }
    return (nswaps == 1)
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
