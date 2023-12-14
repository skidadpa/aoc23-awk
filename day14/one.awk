#!/usr/bin/env gawk -f
BEGIN {
    DEBUG = 0
    FS = ""
}
$0 !~ /^[O..#]+$/ {
    print "DATA ERROR, illegal input", $0
    exit _exit=1
}
{
    if (!ncols) {
        ncols = NF
    } else if (ncols != NF) {
        print "DATA ERROR, width changed from", ncols, "to", NF
    }
    for (i = 1; i <= NF; ++i) {
        columns[i] = $i columns[i]
    }
}
function weight(column,   w, total) {
    total = 0
    for (w = 1; w <= length(column); ++w) {
        if (substr(column, w, 1) == "O") {
            total += w
        }
    }
    if (DEBUG) {
        print "  weight of", column, "is", total
    }
    return total
}
function slide_north(column) {
    while (gsub(/O[.]/, ".O", column)) { }
    return column
}
END {
    if (_exit) {
        exit _exit
    }
    sum = 0
    for (c in columns) {
        if (DEBUG) {
            print "sliding col", columns[c]
        }
        sum += weight(slide_north(columns[c]))
    }
    print sum
}
