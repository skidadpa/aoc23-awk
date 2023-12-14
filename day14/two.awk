#!/usr/bin/env gawk -f
BEGIN {
    DEBUG = 0
    FS = ""
}
$0 !~ /^[O..#]+$/ {
    print "DATA ERROR, illegal input", $0
    exit _exit=1
}
{
    if (!ncols) {
        ncols = NF
    } else if (ncols != NF) {
        print "DATA ERROR, width changed from", ncols, "to", NF
    }
    for (i = 1; i <= NF; ++i) {
        columns[i] = $i columns[i]
    }
}
function weight(   r, total) {
    total = 0
    for (r in rows) {
        total += patsplit(rows[r], dummy, "O") * r
    }
    return total
}
function columns_to_rows(   c, r) {
    for (r = 1; r <= nrows; ++r) {
        rows[r] = ""
        for (c in columns) {
            rows[r] = rows[r] substr(columns[c], r, 1)
        }
    }
}
function columns_to_pattern(   c, pattern) {
    pattern = ""
    for (c in columns) {
        pattern = pattern columns[c]
    }
    return pattern
}
function pattern_to_columns(pattern,  c) {
    for (c = 0; c < ncols; ++c) {
        columns[c + 1] = substr(pattern, c * nrows + 1, nrows)
    }
}
function rows_to_columns(   c, r) {
    for (c = 1; c <= ncols; ++c) {
        columns[c] = ""
        for (r in rows) {
            columns[c] = columns[c] substr(rows[r], c, 1)
        }
    }
}
END {
    if (_exit) {
        exit _exit
    }
    nrows = NR
    sum = 0
    for (cycle = 1; cycle <= 1000000000; ++cycle) {
        for (c in columns) {
            while (gsub(/O[.]/, ".O", columns[c])) { }
        }
        columns_to_rows()
        for (r in rows) {
            while (gsub(/[.]O/, "O.", rows[r])) { }
        }
        rows_to_columns()
        for (c in columns) {
            while (gsub(/[.]O/, "O.", columns[c])) { }
        }
        columns_to_rows()
        for (r in rows) {
            while (gsub(/O[.]/, ".O", rows[r])) { }
        }
        rows_to_columns()
        pattern = columns_to_pattern()
        if (pattern in patterns) {
            if (DEBUG) {
                print "MATCHED at", patterns[pattern], "and", cycle
            }
            range_start = patterns[pattern]
            range_size = cycle - range_start
            cycle = range_start + ((1000000000 - range_start) % range_size)
            break
        }
        patterns[pattern] = cycle
        cycles[cycle] = pattern
    }
    if (DEBUG) {
        print "pattern at cycle", cycle, "is", cycles[cycle]
    }
    pattern_to_columns(cycles[cycle])
    columns_to_rows()
    print weight()
}
