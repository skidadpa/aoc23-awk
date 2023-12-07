#!/usr/bin/env gawk -f
BEGIN {
    phase = 1
}
($0 ~ /^Time:( +[[:digit:]]+)+$/) && (phase == 1) {
    num_races = NF - 1
    ++phase
    for (i = 2; i <= NF; ++i) {
        time[i - 1] = $i + 0
    }
    next
}
($0 ~ /^Distance:( +[[:digit:]]+)+$/) && (phase == 2) && (NF == num_races + 1) {
    ++phase
    for (i = 2; i <= NF; ++i) {
        distance[i - 1] = $i + 0
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
    for (r = 1; r <= num_races; ++r) {
        wins[r] = 0
        for (i = 1; i < time[r]; ++i) {
            if ((time[r] - i) * i > distance[r]) {
                ++wins[r]
            }
        }
    }
    product = 1
    for (r = 1; r <= num_races; ++r) {
        product *= wins[r]
    }
    print product
}
