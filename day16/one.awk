#!/usr/bin/env gawk -f
function report_error(e) { if (_exit_code) exit _exit_code
                           if (e) { print e; exit _exit_code=1 } }
BEGIN {
    DEBUG = 0

    FS = ""

    RIGHT = 0
    DOWN = 1
    LEFT = 2
    UP = 3

    split("", TURN["."])
    split("", ADD["."])

    TURN["/"][RIGHT] = UP
    TURN["/"][DOWN] = LEFT
    TURN["/"][LEFT] = DOWN
    TURN["/"][UP] = RIGHT
    split("", ADD["/"])

    TURN["\\"][RIGHT] = DOWN
    TURN["\\"][DOWN] = RIGHT
    TURN["\\"][LEFT] = UP
    TURN["\\"][UP] = LEFT
    split("", ADD["\\"])

    TURN["|"][RIGHT] = DOWN
    TURN["|"][LEFT] = UP
    ADD["|"][RIGHT] = UP
    ADD["|"][LEFT] = DOWN

    TURN["-"][DOWN] = LEFT
    TURN["-"][UP] = RIGHT
    ADD["-"][DOWN] = RIGHT
    ADD["-"][UP] = LEFT
}
!width { width = NF }
width != NF { report_error("DATA ERROR: width changed from " width " to " NF) }
$0 !~ /^[-|./\\]+$/ { report_error("DATA ERROR: unrecognized row " $0) }
{
    for (c = 1; c <= NF; ++c) {
        grid[c,NR] = $c
    }
}
function move(loc, direction,   coords) {
    split(loc, coords, SUBSEP)
    switch (direction) {
        case "0": # RIGHT
            ++coords[1]
            break
        case "1": # DOWN
            ++coords[2]
            break
        case "2": # LEFT
            --coords[1]
            break
        case "3": # UP
            --coords[2]
            break
        default:
            report_error("PROCESSING ERROR: bad direction " direction)
    }
    return coords[1] SUBSEP coords[2]
}
function coordinates(loc,   coords) {
    split(loc, coords, SUBSEP)
    return "(" coords[1] "," coords[2] ")"
}
function facing(direction) {
    switch (direction) {
        case "0": # RIGHT
            return "RIGHT"
        case "1": # DOWN
            return "DOWN"
        case "2": # LEFT
            return "LEFT"
        case "3": # UP
            return "UP"
    }
    report_error("PROCESSING ERROR: bad direction " direction)
}
END {
    report_error()
    height = NR
    nbeams = 0
    starting_direction[++nbeams] = RIGHT
    starting_location[nbeams] = 1 SUBSEP 1
    split("", energized)
    for (beam = 1; beam <= nbeams; ++beam) {
        direction = starting_direction[beam]
        location = starting_location[beam]
        if (DEBUG) {
            print "beam", beam, "facing", facing(direction), "at", coordinates(location)
        }
        while (location in grid) {
            if (DEBUG) {
                print " energizing", coordinates(location)
            }
            energized[location] = 1
            if ((location SUBSEP direction) in visited) {
                location = 0 SUBSEP 0
                continue
            }
            visited[location, direction] = 1
            tile = grid[location]
            if (direction in ADD[tile]) {
                new_direction = ADD[tile][direction]
                new_location = move(location, new_direction)
                starting_direction[++nbeams] = new_direction
                starting_location[nbeams] = new_location
                if (DEBUG) {
                    print " new beam", nbeams, "facing", facing(new_direction), "at", coordinates(new_location)
                }
            }
            if (direction in TURN[tile]) {
                direction = TURN[tile][direction]
                if (DEBUG) {
                    print " turning", facing(direction)
                }
            }
            location = move(location, direction)
            if (DEBUG) {
                print " moving to", coordinates(location)
            }
        }
    }

    if (DEBUG) {
        print "ENERGIZED TILES:"
        for (r = 1; r <= height; ++r) {
            for (c = 1; c <= width; ++c) {
                printf("%s", ((c SUBSEP r) in energized) ? "#" : ".")
            }
            printf("\n")
        }
    }
    print length(energized)
}
