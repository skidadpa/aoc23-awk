#!/usr/bin/env gawk -f
BEGIN {
    FPAT = "[[:digit:]]"
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
    num = $1 $NF
    sum += num
    if (DEBUG) {
        printf("%s contains %d tokens:", $0, NF)
        for (p = 1; p <= NF; ++p) printf(" %s", $p)
        printf(" => %s\n", num)
    }
}
END {
    if (_exit) {
        exit _exit
    }
    print sum
}
