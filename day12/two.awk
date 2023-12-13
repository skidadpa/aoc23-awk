#!/usr/bin/env gawk -f
BEGIN {
    DEBUG = 0
    sum = 0
}
function indent(depth,   i) {
    for (i = 1; i <= depth; ++i) {
        printf(" ")
    }
}
function num_arrangements(matched, depth, str, broken, idx, num_springs,   count, offset, i) {
    if (DEBUG >= depth) {
        indent(depth)
        printf("recursing on %s, need %d chars for:", str, num_springs)
        for (i = idx; i <= length(broken); ++i) {
            printf(" %d", broken[i])
        }
        printf("\n")
    }
    if ((str SUBSEP idx) in matched) {
        if (DEBUG >= depth) {
            print str, "ALREADY MATCHED TO", matched[str,idx]
        }
        return matched[str,idx]
    }
    if (length(str) < num_springs) {
        if (DEBUG >= depth) {
            indent(depth)
            print str, "MATCHES 0 (NOT ENOUGH CHARS)"
        }
        matched[str,idx] = 0
        return 0
    }
    if (idx > length(broken)) {
        if (match(str, "^[?.]*$")) {
            if (DEBUG >= depth) {
                indent(depth)
                print str, "MATCHES 1 (AT END)"
            }
            matched[str,idx] = 1
            return 1
        } else {
            if (DEBUG >= depth) {
                indent(depth)
                print str, "MATCHES 0 (BROKEN SPRINGS REMAIN)"
            }
            matched[str,idx] = 0
            return 0
        }
    }
    if (substr(str, 1, 1) == "?") {
        if (substr(str, 2, 1) == ".") {
            count = num_arrangements(matched, depth + 1, substr(str, 3), broken, idx, num_springs)
        } else {
            count = num_arrangements(matched, depth + 1, substr(str, 2), broken, idx, num_springs)
        }
    } else {
        count = 0
    }
    if (DEBUG >= depth) {
        indent(depth)
        print str, "FIRST COUNT IS", count
    }
    if (match(str, "^([?#]){" broken[idx] "}[?.]")) {
        if (DEBUG >= depth) {
            indent(depth)
            print str, "MATCHED [" broken[idx] "], TRYING TO MATCH REST"
        }
        num_springs -= broken[idx] + 1
        offset = broken[idx] + 2
        if (substr(str, offset, 1) == ".") {
            ++offset
        }
        count += num_arrangements(matched, depth + 1, substr(str, offset), broken, idx + 1, num_springs)
    } else {
        if (DEBUG >= depth) {
            indent(depth)
            print str, "DOES NOT MATCH [" broken[idx] "]"
        }
    }
    if (DEBUG >= depth) {
        indent(depth)
        print str, "MATCHES", count
    }
    matched[str,idx] = count
    return count
}
$0 !~ /^[.?#]+ [[:digit:]]+(,[[:digit:]]+)*$/ {
    print "DATA ERROR"
    exit _exit=1
}
{
    pattern = $1 "?" $1 "?" $1 "?" $1 "?" $1
    gsub(/(^[.]+)|([.]+$)/, "", pattern)
    gsub(/[.]+/, ".", pattern)
    split($2, broken, ",")
    num_springs = length(broken)
    for (i = 1; i <= num_springs; ++i) {
        broken[i] = broken[num_springs + i] = broken[2 * num_springs + i] = broken[3 * num_springs + i] = broken[4 * num_springs + i] = broken[i] + 0
    }
    num_springs *= 5
    for (i in broken) {
        num_springs += broken[i]
    }
    if (DEBUG) {
        print "pattern to match:", pattern
    }
    split("", matched)
    sum += num_arrangements(matched, 1, pattern ".", broken, 1, num_springs)
}
END {
    if (_exit) {
        exit _exit
    }
    print sum
}
