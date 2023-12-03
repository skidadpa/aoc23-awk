#!/usr/bin/env gawk -f
BEGIN {
    FPAT = "((red)|(green)|(blue)|([[:digit:]]+))"
    limit["red"] = 12
    limit["green"] = 13
    limit["blue"] = 14
    score = 0
    DEBUG = 0
}
/^Game [[:digit:]]+: [[:digit:]]+ ((red)|(green)|(blue))(, [[:digit:]]+ ((red)|(green)|(blue)))*(; [[:digit:]]+ ((red)|(green)|(blue))(, [[:digit:]]+ ((red)|(green)|(blue)))*)*$/ {
    if (DEBUG) {
        print "Game", $1, "has", (NF - 1) / 2, "draws"
    }
    amt = 2
    typ = 3
    while (amt < NF) {
        if ($amt > limit[$typ]) {
            if (DEBUG) {
                print "Game", $1, "is invalid due to", $amt, $typ
            }
            next
        }
        amt += 2
        typ += 2
    }
    if (DEBUG) {
        print "Game", $1, "is valid"
    }
    score += $1
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
    print score
}
