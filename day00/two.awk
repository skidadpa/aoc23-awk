#!/usr/bin/env gawk -f
BEGIN {
}
{
    if (_error) {
        print "DATA ERROR"
        exit _exit=1
    }
}
END {
    if (_exit) {
        exit _exit
    }
    print NR
}
