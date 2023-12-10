#!/usr/bin/env gawk -f
BEGIN {
    DEBUG = 0
}
function not_all_zeros(a,   i) {
    for (i in a) {
        if (a[i]) {
            return 1
        }
    }
    return 0
}
/^-?[[:digit:]]+( -?[[:digit:]]+)*$/ {
    levels = 0
    split("", history[++levels])
    for (i = 1; i <= NF; ++i) {
        history[levels][i] = $i + 0
    }
    while (not_all_zeros(history[levels])) {
        split("", history[++levels])
        for (i = 1; i < length(history[levels - 1]); ++i) {
            history[levels][i] = history[levels - 1][i + 1] - history[levels - 1][i]
        }
    }
    if (DEBUG) {
        for (level = 1; level <= levels; ++level) {
            for (i = 1; i < level; ++i) {
                printf(" ")
            }
            for (i = 1; i <= length(history[level]); ++i) {
                printf(" %d", history[level][i])
            }
            printf("\n")
        }
    }
    while (levels > 1) {
        e = length(history[levels])
        e1 = length(history[levels - 1])
        history[levels - 1][e1 + 1] = history[levels - 1][e1] + history[levels][e]
        if (DEBUG) {
            for (i = 1; i < levels; ++i) {
                printf(" ")
            }
            print history[levels - 1][e1 + 1]
        }
        --levels
    }
    new_value = history[levels][length(history[levels])]
    sum += new_value
    if (DEBUG) {
        print $0, "+", new_value, ":", sum
    }
    next
}
{
    print "DATA ERROR in", $0
    exit _exit=1
}
END {
    if (_exit) {
        exit _exit
    }
    print sum
}
