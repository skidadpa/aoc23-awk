#!/usr/bin/env gawk -f
BEGIN {
    DEBUG = 0
    phase = 1
    FS = ""
    split("^[LR]+$|^$|^[[:alnum:]]{3} = [(][[:alnum:]]{3}, [[:alnum:]]{3}[)]$", patterns, "|")
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
    if ($1 ~ /A$/) {
        starts[$1] = 1
    } else if ($1 ~ /Z$/) {
        targets[$1] = 1
    }
}
END {
    if (_exit) {
        exit _exit
    }
    # Oddly, the input data all has a fixed stride starting at 0, for everything except the first 2 samples
    # Dealing with those cases here:
    if (length(starts) == 1) {
        if (DEBUG) {
            print "single start, looking for first match"
        }
        steps = 0
        for (e in starts) {
            element = e
            while (!(element in targets)) {
                element = route[element, moves[steps % buffer_size]]
                ++steps
            }
        }
        print steps
        exit 0
    }
    # Finding the strides
    for (e in starts) {
        element = e
        steps = 0
        last_hit = 0
        stride = 0
        hits = 0
        while (hits < 3) {
            element = route[element, moves[steps % buffer_size]]
            ++steps
            if (element in targets) {
                if (stride && (stride != (steps - last_hit))) {
                    print "PROCESSING ERROR, program stride constancy assumption violated"
                    exit 1
                }
                stride = steps - last_hit
                last_hit = steps
                ++hits
            }
        }
        if ((buffer_size > 6) && (stride % buffer_size)) {
            print "PROCESSING ERROR, program stride divisibility assumption violated"
            exit 1
        }
        strides[e] = stride
        if (DEBUG) {
            print "stride for", e, "is", stride, stride / buffer_size
        }
    }
    if (buffer_size > 6)
    {
        for (e in strides) {
            strides[e] /= buffer_size
        }
    }
    product = 1
    for (e in strides) {
        product *= strides[e]
    }
    if (buffer_size >= 6) {
        product *= buffer_size
    }
    print product
}
