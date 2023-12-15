#!/usr/bin/env gawk -f
BEGIN {
    DEBUG = 0
    FS = ","
    for (c = 0; c <= 255; ++c) {
        ord[sprintf("%c",c)] = c
    }
    sum = 0
}
function hash(str,   value, i) {
    value = 0
    for (i = 1; i <= length(str); ++i) {
        value += ord[substr(str,i,1)]
        value *= 17
        value %= 256
    }
    return value
}
{
    for (i = 1; i <= NF; ++i) {
        if (DEBUG) {
            print "hash of", $i, "is", hash($i)
        }
        sum += hash($i)
    }
}
END {
    if (_exit) {
        exit _exit
    }
    print sum
}
