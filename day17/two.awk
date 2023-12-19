#!/usr/bin/env gawk -f
function report_error(e) { if (_exit_code) exit _exit_code
                           if (e) { print e; exit _exit_code=1 } }
BEGIN {
    DEBUG = 0

    FS = ""

    EAST = 0
    SOUTH = 1
    WEST = 2
    NORTH = 3

    upper_move_limit = 0
}
function coordinates(loc,   coords) {
    split(loc, coords, SUBSEP)
    return "(" coords[1] "," coords[2] ")"
}
function facing(dir,   coords) {
    switch (dir) {
        case "0": # EAST
            return "EAST"
        case "1": # SOUTH
            return "SOUTH"
        case "2": # WEST
            return "WEST"
        case "3": # NORTH
            return "NORTH"
        default:
            report_error("PROCESSING ERROR, bad direction " dir)
    }
}
function move(from, dir, amt,   coords) {
    split(from, coords, SUBSEP)

    switch (dir) {
        case "0": # EAST
            coords[1] += amt
            break
        case "1": # SOUTH
            coords[2] += amt
            break
        case "2": # WEST
            coords[1] -= amt
            break
        case "3": # NORTH
            coords[2] -= amt
            break
        default:
            report_error("PROCESSING ERROR, bad direction " dir)
    }
    return coords[1] SUBSEP coords[2]
}
$0 !~ /^[[:digit:]]+$/ { report_error("DATA ERROR in " $0) }
{
    for (c = 1; c <= NF; ++c) {
        loss = $c + 0
        city[c,NR] = loss
        upper_loss_limit += loss
    }
    destination = NF SUBSEP NR
}
END {
    report_error()

    moves[0][1,1][EAST] = 10
    moves[0][1,1][SOUTH] = 10

    for (loss = 0; loss <= upper_loss_limit; ++loss) {
        for (location in moves[loss]) {
            if (DEBUG) {
                print loss ":", coordinates(location)
            }
            if (location == destination) {
                print loss
                exit 0
            }
            for (direction in moves[loss][location]) {
                remaining = moves[loss][location][direction]
                moving = (remaining < 10) ? 1 : 4
                target = move(location, direction, moving)
                if (!(target in city)) {
                    continue
                }
                propagating = remaining - moving
                if (remaining < 10) {
                    if ((target in visited) && (direction in visited[target]) && ((visited[target][direction] % 10) >= propagating)) {
                        continue
                    }
                    visited[target][direction] = visited[target][direction] - (visited[target][direction] % 10) + propagating
                } else {
                    if ((target in visited) && (direction in visited[target]) && (visited[target][direction] >= 10)) {
                        continue
                    }
                    visited[target][direction] = 10 + (visited[target][direction] % 10)
                }
                new_loss = city[target]
                if (moving == 4) {
                    new_loss += city[move(location, direction, 1)]
                    new_loss += city[move(location, direction, 2)]
                    new_loss += city[move(location, direction, 3)]
                }
                if (DEBUG) {
                    print "CAN MOVE", facing(direction), "TO", coordinates(target), "losing", new_loss
                }
                moves[loss + new_loss][target][(direction + 1) % 4] = 10
                moves[loss + new_loss][target][(direction + 3) % 4] = 10
                if ((propagating > 0) && (moves[loss + new_loss][target][direction] < propagating)) {
                    moves[loss + new_loss][target][direction] = propagating
                }
            }
        }
    }

    print "VISITED:"
    for (r = 1; r <= NR; ++r) {
        for (c = 1; c <= NF; ++c) {
            if ((c SUBSEP r) in visited) {
                printf("*")
            } else {
                printf(".")
            }
        }
        printf("\n")
    }

    report_error("PROCESSING ERROR, did not hit destination after " loss)
}
