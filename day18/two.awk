#!/usr/bin/env gawk -f
function report_error(e) { if (_exit_code) exit _exit_code
                           if (e) { print e; exit _exit_code=1 } }
function coordinates(loc,   coords) {
    split(loc, coords, SUBSEP)
    return "(" coords[1] "," coords[2] ")"
}
function box_out(d,    coords) {
    trench[digger] = 1
    split(d, coords, SUBSEP)
    vert_cuts[coords[1]] = vert_cuts[coords[1] + 1] = horiz_cuts[coords[2]] = horiz_cuts[coords[2] + 1] = 1
}
function move(from, dir, dist,   coords, x, y) {
    split(from, coords, SUBSEP)
    x = coords[1] + 0
    y = coords[2] + 0
    switch (dir) {
        case "R":
            x += dist
            break
        case "D":
            y += dist
            break
        case "L":
            x -= dist
            break
        case "U":
            y -= dist
            break
        default:
            report_error("PROCESSING ERROR, unrecognized direction " dir)
    }
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
    return x SUBSEP y
}
function find_outside(loc,    coord0, coord1) {
    if ((loc in outside) || (loc in trench)) {
        return
    }
    outside[loc] = 1
    split(loc, coord0, SUBSEP)
    split(regions[loc], coord1, SUBSEP)
    if ((coord0[1] SUBSEP coord1[2]) in regions) {
        find_outside(coord0[1] SUBSEP coord1[2])
    }
    if ((coord1[1] SUBSEP coord0[2]) in regions) {
        find_outside(coord1[1] SUBSEP coord0[2])
    }
    if ((coord0[1] SUBSEP coord1[2]) in region_ends) {
        find_outside(region_ends[coord0[1], coord1[2]])
    }
    if ((coord1[1] SUBSEP coord0[2]) in region_ends) {
        find_outside(region_ends[coord1[1], coord0[2]])
    }
}
BEGIN {
    DEBUG = 0
    OLD_WAY = 0
    FPAT = "[UDLR]|[[:digit:]]+|[0-9a-f]{6}"
    split("RDLU", directions, "")
    xmin = xmax = ymin = ymax = 0
    digger = 0 SUBSEP 0
    box_out(digger)
    split("", trench)
}
$0 !~ /^[UDLR] [[:digit:]]+ [(][#][0-9a-f]{5}[0-3][)]$/ { report_error("DATA ERROR: " $0) }
{
    if (OLD_WAY) {
        len = $2 + 0
        dir = $1
    } else {
        len = strtonum("0x" substr($3, 1, 5))
        dir = directions[substr($3, 6, 1) + 1]
    }
    move_to = move(digger, dir, len)
    if (digger in trench_directions) {
        report_error("PROCESSING_ERROR: multiple trenches from same start not currently supported")
    }
    if (DEBUG > 1) {
        print "dig", dir, len, "from", coordinates(digger), "to", coordinates(move_to)
    }
    trench_directions[digger] = dir
    trench_lengths[digger] = len + 0
    digger = move_to
    box_out(digger)
}
END {
    PROCINFO["sorted_in"] = "@ind_num_asc"
    report_error()
    if (digger != (0 SUBSEP 0)) {
        print "NOTE: trench did not end up back at start"
    }
    vert_cuts[xmin - 1] = vert_cuts[xmax + 2] = horiz_cuts[ymin - 1] = horiz_cuts[ymax + 2] = 1

    if (DEBUG > 3) {
        for (v in vert_cuts) {
            print "VERTICAL CUT AT", v
        }
        for (h in horiz_cuts) {
            print "HORIZONTAL CUT AT", h
        }
    }
    vert_cuts[xmin - 1] = vert_cuts[xmax + 2] = horiz_cuts[ymin - 1] = horiz_cuts[ymax + 2] = 1

    for (t in trench_directions) {
        split(t, coords, SUBSEP)
        x = coords[1] + 0
        y = coords[2] + 0
        len = trench_lengths[t]
        if (DEBUG > 3) {
            print "TRENCH", trench_directions[t], len, "FROM", coordinates(t), ":"
        }
        switch (trench_directions[t]) {
            case "R":
                for (v in vert_cuts) {
                    if (((v + 0) > x) && ((v + 0) < (x + len))) {
                        trench[v,y] = 1
                        if (DEBUG > 3) {
                            printf(" (%d,%d)\n", v, y)
                        }
                    }
                }
                break
            case "D":
                for (h in horiz_cuts) {
                    if (((h + 0) > y) && ((h + 0) < (y + len))) {
                        trench[x,h] = 1
                        if (DEBUG > 3) {
                            printf(" (%d,%d)\n", x, h)
                        }
                    }
                }
                break
            case "L":
                for (v in vert_cuts) {
                    if (((v + 0) < x) && ((v + 0) > (x - len))) {
                        trench[v,y] = 1
                        if (DEBUG > 3) {
                            printf(" (%d,%d)\n", v, y)
                        }
                    }
                }
                break
            case "U":
                for (h in horiz_cuts) {
                    if (((h + 0) < y) && ((h + 0) > (y - len))) {
                        trench[x,h] = 1
                        if (DEBUG > 3) {
                            printf(" (%d,%d)\n", x, h)
                        }
                    }
                }
                break
            default:
                report_error("PROCESSING ERROR, unrecognized direction " dir)
        }
    }
    h0 = "NONE"
    for (h in horiz_cuts) {
        if (h0 == "NONE") {
            h0 = h
            continue
        }
        v0 = "NONE"
        for (v in vert_cuts) {
            if (v0 == "NONE") {
                v0 = v
                continue
            }
            regions[v0, h0] = (v SUBSEP h)
            region_ends[v,h] = (v0 SUBSEP h0)
            region_area[v0,h0] = (v - v0) * (h - h0)
            if (DEBUG) {
                print "REGION", coordinates(v0 SUBSEP h0) ":" coordinates(v SUBSEP h), "area", region_area[v0,h0]
            }
            v0 = v
        }
        h0 = h
    }
    find_outside((xmin - 1) SUBSEP (ymin - 1))
    PROCINFO["sorted_in"] = "@unsorted"
    for (r in regions) {
        if (!(r in outside) && !(r in trench)) {
            if (DEBUG > 1) {
                print "REGION", coordinates(r) ":" coordinates(regions[r]), "is inside"
            }
            inside[r] = 1
        }
    }
    total_trench = 0
    total_inside = 0
    total_outside = 0
    total = (3 + xmax - xmin) * (3 + ymax - ymin)
    for (r in trench) {
        total_trench += region_area[r]
    }
    for (r in inside) {
        total_inside += region_area[r]
    }
    for (r in outside) {
        total_outside += region_area[r]
    }
    if (DEBUG > 3) {
        for (y = ymin - 1; y <= ymax + 1; ++y) {
            for (x = xmin - 1; x <= xmax + 1; ++x) {
                loc = x SUBSEP y
                loc_region = "NOT FOUND"
                if (loc in regions) {
                    loc_region = loc
                } else {
                    for (r in regions) {
                        split(r, coord0, SUBSEP)
                        split(regions[r], coord1, SUBSEP)
                        if ((x >= (coord0[1] + 0)) && (x < (coord1[1] + 0)) && (y >= (coord0[2] + 0)) && (y < (coord1[2] + 0))) {
                            loc_region = r
                            break
                        }
                    }
                }

                if (loc_region in trench) {
                    printf("*")
                } else if (loc_region in outside) {
                    printf("O")
                } else if (loc_region in inside) {
                    printf(".")
                } else {
                    printf("X")
                }
            }
            printf("\n")
        }
    }
    if (DEBUG) {
        print total "=" total_outside "+" total_trench "+" total_inside
    }
    print total_trench + total_inside
}
