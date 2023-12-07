#!/usr/bin/env gawk -f
BEGIN {
    phase = 1
}
($0 ~ /^Time:( +[[:digit:]]+)+$/) && (phase == 1) {
    ++phase
    time = ""
    for (i = 2; i <= NF; ++i) {
        time = time $i
    }
    time = time + 0
    next
}
($0 ~ /^Distance:( +[[:digit:]]+)+$/) && (phase == 2) {
    ++phase
    distance = ""
    for (i = 2; i <= NF; ++i) {
        distance = distance $i
    }
    distance = distance + 0
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
    wins = 0
    for (i = 1; i < time; ++i) {
        if ((time - i) * i > distance) {
            ++wins
        }
    }
    print wins
}
