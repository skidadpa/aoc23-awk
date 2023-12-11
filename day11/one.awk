#!/usr/bin/env gawk -f
BEGIN {
    FS = ""
    DEBUG = 0
}
$0 !~ /^[.#]+$/ {
    print "DATA ERROR"
    exit _exit=1
}
/^[.]+$/ {
    ++rows
}
{
    ++rows
    for (image_column = 1; image_column <= NF; ++image_column) {
        if ($image_column == "#") {
            image_galaxies[rows][image_column] = 1
            image_columns_with_galaxies[image_column] = 1
            if (DEBUG) {
                printf("galaxy image detected at (%d,%d)\n", NR, image_column)
            }
        }
    }
    if (!cols) {
        cols = NF
    } else if (cols != NF) {
        print "DATA ERROR, saw", NF, "columns, expected", cols
        exit _exit=1
    }
}
function coord_distance(p1, p2) {
    if (p1 + 0 > p2 + 0) {
        return p1 - p2
    }
    return p2 - p1
}
END {
    if (_exit) {
        exit _exit
    }
    offset = 0
    for (image_column = 1; image_column <= cols; ++image_column) {
        if (image_column in image_columns_with_galaxies) {
            offsets[image_column] = offset
        } else {
            ++offset
        }
    }
    galaxies = 0
    for (row in image_galaxies) {
        for (image_column in image_galaxies[row]) {
            if (DEBUG) {
                printf("galaxy calculated at (%d,%d)\n", row, image_column + offsets[image_column])
            }
            ++galaxies
            x[galaxies] = row
            y[galaxies] = image_column + offsets[image_column]
        }
    }
    if (DEBUG) {
        print galaxies, "galaxies processed"
        pairs = 0
    }
    sum = 0
    for (g1 = 1; g1 < galaxies; ++g1) {
        for (g2 = g1 + 1; g2 <= galaxies; ++g2) {
            distance = coord_distance(x[g1], x[g2]) + coord_distance(y[g1], y[g2])
            sum += distance
            if (DEBUG) {
                printf("distance from (%d,%d) to (%d,%d) is %d : %d\n", x[g1], y[g1], x[g2], y[g2], distance, sum)
                ++pairs
            }
        }
    }
    if (DEBUG) {
        print pairs, "galaxy pairs processed"
    }
    print sum
}
