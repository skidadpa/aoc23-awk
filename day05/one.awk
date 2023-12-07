#!/usr/bin/env gawk -f
BEGIN {
    FS = "[- ]"
    DEBUG = 0
}
/^seeds:( [[:digit:]]+)+$/ {
    if (DEBUG) {
        print "starting", $0
    }
    from = "start"
    to = "seed"
    for (i = 2; i <= NF; ++i) {
        items[to][$i] = matched[from][$i] = 1
    }
    next
}
/^([[:alpha:]]+)-to-([[:alpha:]]+) map:$/ {
    if (to != $1) {
        print "DATA ERROR, not mapping from", to
        exit _exit=1
    }
    if (DEBUG) {
        if (length(matched[from]) < length(items[from])) {
            print " convert remaining", from, "directly to", to
        } else if (from != "start") {
            print " all", from, "converted to", to
        }
    }
    for (i in items[from]) {
        if (!(i in matched[from])) {
            if (DEBUG > 1) {
                print " ", from, i, "->", to, i
            }
            items[to][i] = 1
        }
    }
    if (DEBUG) {
        print "converting", $1, "to", $3
    }
    from = $1
    to = $3
    next
}
/^$/ {
    next
}
/^[[:digit:]]+ [[:digit:]]+ [[:digit:]]+$/ {
    beg = $2 + 0
    end = $2 + $3
    offset = $1 - $2
    if (DEBUG) {
        printf(" [%d:%d): %+d\n", beg, end, offset)
    }
    for (i in items[from]) {
        if ((i + 0 >= beg) && (i + 0 < end)) {
            if (DEBUG > 1) {
                print " ", from, i, "->", to, i + offset
            }
            items[to][i + offset] = 1
            matched[from][i] = 1
        }
    }
    next
}
{
    print "DATA ERROR"
    exit _exit=1
}
END {
    if (_exit) {
        exit _exit
    }
    if (to != "location") {
        print "DATA ERROR, did not end on location"
        exit 1
    }
    if (DEBUG) {
        if (length(matched[from]) < length(items[from])) {
            print " convert remaining", from, "directly to", to
        } else {
            print " all", from, "converted to", to
        }
    }
    for (i in items[from]) {
        if (!(i in matched[from])) {
            if (DEBUG > 1) {
                print " ", from, i, "->", to, i
            }
            items[to][i] = 1
        }
    }
    if (DEBUG) {
        print "end of conversions"
    }
    lowest = -1
    for (i in items[to]) {
        if ((i + 0 < lowest) || (lowest < 0)) {
            lowest = i + 0
        }
    }
    print lowest
}
