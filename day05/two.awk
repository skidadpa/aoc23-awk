#!/usr/bin/env gawk -f
BEGIN {
    FS = "[- ]"
    DEBUG = 0
}
/^seeds:( [[:digit:]]+)+$/ {
    if (DEBUG) {
        print "starting seeds"
    }
    from = "start"
    to = "seed"
    for (start = 2; start < NF; start += 2) {
        len = start + 1
        if (DEBUG) {
            print " [" $start ":" $start + $len ")"
        }
        items[to][$start] = matched[from][$start] = $len + 0
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
                print " ", from, "[" i ":" i + items[from][i] ") ->", to, "[" i ":" i + items[from][i] ")"
            }
            items[to][i] = items[from][i]
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
    len = $3 + 0
    end = $2 + len
    offset = $1 - $2
    if (DEBUG) {
        printf(" [%d:%d): %+d\n", beg, end, offset)
    }
    split("", new)
    for (i in items[from]) {
        if ((i + 0 < beg) && (i + items[from][i] >= beg)) {
            if (i + items[from][i] >= end) {
                new[beg] = len
                new[end] = i + items[from][i] - end
            } else {
                new[beg] = i + items[from][i] - beg
            }
            items[from][i] = beg - i
        } else if ((i + 0 < end) && (i + items[from][i] > end)) {
            new[end] = i + items[from][i] - end
            items[from][i] = end - i
        }
    }
    for (i in new) {
        items[from][i] = new[i]
    }
    for (i in items[from]) {
        if ((i + 0 >= beg) && (i + 0 < end)) {
            if (DEBUG > 1) {
                print " ", from, "[" i ":" i + items[from][i] ") ->", to, "[" i + offset ":" i + offset + items[from][i] ")"
            }
            items[to][i + offset] = items[from][i]
            matched[from][i] = items[from][i]
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
                print " ", from, "[" i ":" i + items[from][i] ") ->", to, "[" i ":" i + items[from][i] ")"
            }
            items[to][i] = items[from][i]
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
