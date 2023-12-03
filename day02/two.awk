#!/usr/bin/env gawk -f
BEGIN {
    FPAT = "((red)|(green)|(blue)|([[:digit:]]+))"
    score = 0
    DEBUG = 0
}
/^Game [[:digit:]]+: [[:digit:]]+ ((red)|(green)|(blue))(, [[:digit:]]+ ((red)|(green)|(blue)))*(; [[:digit:]]+ ((red)|(green)|(blue))(, [[:digit:]]+ ((red)|(green)|(blue)))*)*$/ {
    limit["red"] = limit["green"] = limit["blue"] = 0
    amt = 2
    typ = 3
    while (amt < NF) {
        if ($amt > limit[$typ]) {
            limit[$typ] = $amt
        }
        amt += 2
        typ += 2
    }
    power = limit["red"] * limit["green"] * limit["blue"]
    if (DEBUG) {
        print "Game", $1, "has", (NF - 1) / 2, "draws and its power is", power
    }
    score += power
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
