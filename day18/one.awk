#!/usr/bin/env gawk -f
function report_error(e) { if (_exit_code) exit _exit_code
                           if (e) { print e; exit _exit_code=1 } }
BEGIN {
    DEBUG = 0
    FPAT = "[UDLR]|[[:digit:]]+|[0-9a-f]{6}"
    split("RDLU", directions, "")
    digger = 0 SUBSEP 0
    xmin = xmax = ymin = ymax = 0
    split("", trench)
}
function move(from, dir, color,   coords, x, y) {
    split(from, coords, SUBSEP)
    x = coords[1] + 0
    y = coords[2] + 0
    switch (dir) {
        case "R":
            ++x
            break
        case "D":
            ++y
            break
        case "L":
            --x
            break
        case "U":
            --y
            break
        default:
            report_error("PROCESSING ERROR, unrecognized direction " dir)
    }
    if (color != "") {
        trench[x,y] = color
        if (xmin > x) {
            xmin = x
        }
        if (xmax < x) {
            xmax = x
        }
        if (ymin > y) {
            ymin = y
        }
        if (ymax < y) {
            ymax = y
        }
    }
    return x SUBSEP y
}
$0 !~ /^[UDLR] [[:digit:]]+ [(][#][0-9a-f]{6}[)]$/ { report_error("DATA ERROR: " $0) }
{
    trench_length = $2 + 0
    if (DEBUG > 1) {
        print "dig", $1, "by", trench_length, "painting", $3
    }
    for (i = 1; i <= trench_length; ++i) {
        digger = move(digger, $1, $3)
    }
}
END {
    report_error()
    split("", outside)
    for (y = ymin - 2; y <= ymax + 2; ++y) {
        outside[xmin - 2, y] = 1
        outside[xmax + 2, y] = 1
    }
    for (x = xmin - 2; x <= xmax + 2; ++x) {
        outside[x, ymin - 2] = 1
        outside[x, ymax + 2] = 1
    }
    add_level = 1
    split("", adds[add_level])
    for (y = ymin - 1; y <= ymax + 1; ++y) {
        adds[add_level][xmin - 1, y] = 1
        adds[add_level][xmax + 1, y] = 1
    }
    for (x = xmin - 1; x <= xmax + 1; ++x) {
        adds[add_level][x, ymin - 1] = 1
        adds[add_level][x, ymax + 1] = 1
    }
    while (length(adds[add_level])) {
        next_level = add_level + 1
        split("", adds[next_level])

        for (loc in adds[add_level]) {
            outside[loc] = 1
            for (d in directions) {
                move_loc = move(loc, directions[d])
                if ((move_loc in outside) || (move_loc in trench)) {
                    continue
                }
                adds[next_level][move_loc] = 1
            }
        }

        delete adds[add_level]
        add_level = next_level
    }
    for (y = ymin - 1; y <= ymax + 1; ++y) {
        for (x = xmin - 1; x <= xmax + 1; ++x) {
            loc = x SUBSEP y
            if ((loc in trench) || (loc in outside)) {
                continue
            }
            inside[loc] = 1
        }
    }
    if (DEBUG) {
        for (y = ymin - 1; y <= ymax + 1; ++y) {
            for (x = xmin - 1; x <= xmax + 1; ++x) {
                loc = x SUBSEP y
                if (loc in trench) {
                    printf("=")
                } else if (loc in outside) {
                    printf("O")
                } else if (loc in inside) {
                    printf(".")
                } else {
                    printf("X")
                }
            }
            printf("\n")
        }
    }
    print length(trench) + length(inside)
}
