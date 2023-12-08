#!/usr/bin/env gawk -f
BEGIN {
    split("23456789TJQKA", cards, "")
    for (v in cards) {
        card_value[cards[v]] = v + 1
    }
    DEBUG = 0
}
$0 !~ /^[2-9TJQKA]{5} [[:digit:]]+$/ {
    print "DATA ERROR, illegal format:", $0
    exit _exit=1
}
{
    hand_value[$1] = hand_type($1)
    bid[$1] = $2 + 0
}
function hand_type(hand,   hand_cards, counts)
{
    split(hand, hand_cards, "")
    split("", counts)

    PROCINFO["sorted_in"] = "@unsorted"
    for (c in hand_cards) {
        ++counts[hand_cards[c]]
    }

    PROCINFO["sorted_in"] = "@val_num_desc"
    last_count = 0
    for (c in counts) {
        switch (counts[c]) {
            case 5:
                return 7
            case 4:
                return 6
            case 3:
                break
            case 2:
                switch (last_count) {
                    case 3:
                        return 5
                    case 2:
                        return 3
                }
                break
            case 1:
                switch (last_count) {
                    case 3:
                        return 4
                    case 2:
                        return 2
                }
                return 1
        }
        last_count = counts[c]
    }
}
function cmp_hands(i1, v1, i2, v2,   ci, c1, c2) {
    if (hand_value[i1] != hand_value[i2]) {
        return hand_value[i1] - hand_value[i2]
    }
    for (ci = 1; ci <= length(i1); ++ci) {
        c1 = substr(i1,ci,1)
        c2 = substr(i2,ci,1)
        if (c1 != c2) {
            return card_value[c1] - card_value[c2]
        }
    }
    return 0
}
END {
    if (_exit) {
        exit _exit
    }
    sum = 0
    asorti(hand_value, hand_ranks, "cmp_hands")
    PROCINFO["sorted_in"] = "@ind_num_asc"
    for (rank in hand_ranks) {
        hand = hand_ranks[rank]
        if (DEBUG) {
            print hand, "hand_value", hand_value[hand], "rank", rank, "bid", bid[hand], "value", rank * bid[hand]
        }
        sum += rank * bid[hand]
    }
    print sum
}
