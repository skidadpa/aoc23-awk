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
    if (!width) {
        width = NF
    } else if (width != NF) {
        print "DATA ERROR, expected width", width, "saw", NF, "at", $0
        exit _exit=1
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
    height = NR
    if (DEBUG) {
        print width, "x", height, "map"
    }
    tubes[p1] = map[p1]
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
            if (DEBUG > 1) {
                print "Path 1 starts", move_names[dir]
            }
            p1 = move(p1, dir)
            b1 = back[dir]
            tubes[p1] = map[p1]
            break
        }
    }
    for (++dir ; dir < 4; ++dir) {
        if (dir in can_go["S"]) {
            if (DEBUG > 1) {
                print "Path 2 starts", move_names[dir]
            }
            p2 = move(p2, dir)
            b2 = back[dir]
            tubes[p2] = map[p2]
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
        tubes[p1] = map[p1]
        if (DEBUG > 1) {
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
        tubes[p2] = map[p2]
        if (DEBUG > 1) {
            print "Path 2 moves", move_names[dir]
        }
    }
    split("", inside)
    split("", outside)
    for (y = 1; y <= height; ++y) {
        outside_next[y] = 1
    }
    for (x = 1; x <= width; ++x) {
        for (y = 1; y <= height; ++y) {
            if ((x SUBSEP y) in tubes) {
                if (UP in can_go[tubes[x,y]]) {
                    outside_next[y] = !(outside_next[y])
                }
            } else if (outside_next[y]) {
                outside[x,y] = 1
            } else {
                inside[x,y] = 1
            }
        }
    }
    if (DEBUG) {
        for (y = 1; y <= height; ++y) {
            for (x = 1; x <= width; ++x) {
                if ((x SUBSEP y) in tubes) {
                    printf("%s", tubes[x,y])
                } else if ((x SUBSEP y) in outside) {
                    printf("O")
                } else if ((x SUBSEP y) in inside) {
                    printf("I")
                } else {
                    printf(".")
                }
            }
            printf("\n")
        }
        print "INTERIOR LOCATIONS:"
        for (i in inside) {
            split(i, coords, SUBSEP)
            printf(" (%d,%d)\n", coords[1], coords[2])
        }
    }

    print length(inside)
}
