#!/usr/bin/env gawk -f
BEGIN {
    DEBUG = 0
    phase = 1
    FS = ""
    split("^[LR]+$|^$|^[[:alpha:]]{3} = [(][[:alpha:]]{3}, [[:alpha:]]{3}[)]$", patterns, "|")
    if (DEBUG > 3) {
        for (p in patterns) {
            print "pattern", p, ":", patterns[p]
        }
    }
}
$0 !~ patterns[phase] {
    print "DATA ERROR in phase", phase, "expecting", patterns[phase]
    exit _exit=1
}
phase == 1 {
    if (DEBUG) {
        print "move buffer contains", NF, "elements:", $0
    }
    for (i = 1; i <= NF; ++i) {
        moves[i - 1] = $i
    }
    buffer_size = NF
    ++phase
    next
}
phase == 2 {
    if (DEBUG > 1) {
        print "Routes:"
    }
    FS = "[ =,()]+"
    ++phase
    next
}
phase == 3 {
    if (DEBUG > 1) {
        print $1, ": L ->", $2, "; R ->", $3
    }
    route[$1, "L"] = $2
    route[$1, "R"] = $3
}
END {
    if (_exit) {
        exit _exit
    }
    steps = 0
    element = "AAA"
    if (DEBUG) {
        print "starting at element", element
    }
    while (element != "ZZZ")
    {
        element = route[element, moves[steps % buffer_size]]
        ++steps
        if (DEBUG) {
            print "step", steps, ": moved to element", element
        }
    }
    print steps
}
