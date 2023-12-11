#!/usr/bin/env gawk -f
BEGIN {
    DEBUG = 0
    UP = 0
    RIGHT = 1
    DOWN = 2
    LEFT = 3
    if (DEBUG) {
        split("RIGHT DOWN LEFT", move_names)
        move_names[UP] = "UP"
    }
    can_go["|"][UP] = can_go["L"][UP] = can_go["J"][UP] = 1
    can_go["|"][DOWN] = can_go["7"][DOWN] = can_go["F"][DOWN] = 1
    can_go["-"][RIGHT] = can_go["L"][RIGHT] = can_go["F"][RIGHT] = 1
    can_go["-"][LEFT] = can_go["J"][LEFT] = can_go["7"][LEFT] = 1
    back[UP] = DOWN
    back[RIGHT] = LEFT
    back[DOWN] = UP
    back[LEFT] = RIGHT
    split("", can_go["."])
    FS = ""
}
$0 !~ /^[-|LJ7F.S]+$/ {
    print "DATA ERROR in", $0
    exit _exit=1
}
{
    for (i = 1; i <= NF; ++i) {
        map[i,NR] = $i
        if ($i == "S") {
            if (p1) {
                printf("DATA ERROR, start at both (%d,%d) and (%d,%d)\n", x1, y1, i, NR)
                exit _exit=1
            }
            p1 = p2 = i SUBSEP NR
        }
    }
    map_size += NF
}
function move(p, dir,   coords) {
    split(p, coords, SUBSEP)
    switch (dir) {
        case "0": # UP
            coords[2] -= 1
            break
        case "1": # RIGHT
            coords[1] += 1
            break
        case "2": # DOWN
            coords[2] += 1
            break
        case "3": # LEFT
            coords[1] -= 1
            break
    }
    return coords[1] SUBSEP coords[2]
}
END {
    if (_exit) {
        exit _exit
    }
    for (dir = 0; dir < 4; ++dir) {
        if (back[dir] in can_go[map[move(p1, dir)]]) {
            can_go["S"][dir] = 1
        }
    }
    if (length(can_go["S"]) != 2) {
        print "DATA ERROR,", length(can_go["S"]), "ways to leave start, should be 2"
        exit _exit=1
    }
    for (dir = 0; dir < 4; ++dir) {
        if (dir in can_go["S"]) {
            if (DEBUG) {
                print "Path 1 starts", move_names[dir]
            }
            p1 = move(p1, dir)
            b1 = back[dir]
            break
        }
    }
    for (++dir ; dir < 4; ++dir) {
        if (dir in can_go["S"]) {
            if (DEBUG) {
                print "Path 2 starts", move_names[dir]
            }
            p2 = move(p2, dir)
            b2 = back[dir]
            break
        }
    }
    if (dir >= 4) {
        print "PROCESSING ERROR, could not find two starting paths"
        exit _exit=1
    }
    for (steps = 1; (p1 != p2) && (steps <= map_size / 2); ++steps) {
        for (dir = (b1 + 1) % 4; dir != b1; dir = (dir + 1) % 4) {
            if (dir in can_go[map[p1]]) {
                break
            }
        }
        if (dir == b1) {
            print "PROCESSING ERROR, path 1 moved backward"
            exit _exit=1
        }
        p1 = move(p1, dir)
        b1 = back[dir]
        if (DEBUG) {
            print "Path 1 moves", move_names[dir]
        }
        if (p1 == p2) {
            break
        }
        for (dir = (b2 + 1) % 4; dir != b2; dir = (dir + 1) % 4) {
            if (dir in can_go[map[p2]]) {
                break
            }
        }
        if (dir == b2) {
            print "PROCESSING ERROR, path 2 moved backward"
            exit _exit=1
        }
        p2 = move(p2, dir)
        b2 = back[dir]
        if (DEBUG) {
            print "Path 2 moves", move_names[dir]
        }
    }
    print steps
}
