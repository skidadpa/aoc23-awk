#!/usr/bin/env gawk -f
BEGIN {
    FPAT = "([[:digit:]]+)|([|])"
    sum = 0
    DEBUG = 0
}
/^Card +[[:digit:]]+:( +[[:digit:]]+)+ +|( +[[:digit:]]+)+$/ {
    split("", winning)
    recording_winners = 1
    card_score = 0
    for (i = 2; i <= NF; ++i) {
        if ($i == "|") {
            recording_winners = 0
        } else if (recording_winners) {
            winning[$i] = 1
        } else if ($i in winning) {
            if (card_score < 1) {
                card_score = 1
            } else {
                card_score *= 2
            }
        }
    }
    if (DEBUG) {
        print "Card", $1, "scores", card_score
    }
    sum += card_score
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
    print sum
}
