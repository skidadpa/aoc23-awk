#!/usr/bin/env gawk -f
BEGIN {
    FPAT = "([[:digit:]])|(one)|(two)|(three)|(four)|(five)|(six)|(seven)|(eight)|(nine)"
    value["0"] = "0"
    value["1"] = "1"
    value["2"] = "2"
    value["3"] = "3"
    value["4"] = "4"
    value["5"] = "5"
    value["6"] = "6"
    value["7"] = "7"
    value["8"] = "8"
    value["9"] = "9"
    value["one"] = "1"
    value["two"] = "2"
    value["three"] = "3"
    value["four"] = "4"
    value["five"] = "5"
    value["six"] = "6"
    value["seven"] = "7"
    value["eight"] = "8"
    value["nine"] = "9"
    sum = 0
    DEBUG = 0
}
(NF < 1) {
    if (_error) {
        print "DATA ERROR"
        exit _exit=1
    }
}
{
    last = last_match($0, FPAT)
    num = value[$1] value[last]
    sum += num
    if (DEBUG) {
        printf("%s: %s\n", $0, num)
    }
}
function last_match(str, pat,    i) {
    for (i = length(str); i > 0; --i) {
        rstr = substr(str, i)
        if (match(rstr, FPAT)) {
            return substr(rstr, RSTART, RLENGTH)
        }
    }
    if (_error) {
        print "PROCESSING ERROR"
        exit _exit=1
    }
}
END {
    if (_exit) {
        exit _exit
    }
    print sum
}
