package main

import "core:time"
import "core:fmt"
import "core:strings"
import "core:os"
import "core:math"


/// Day 4
///
/// P1: Wordsearch for XMAS in 8 directions
/// P2: Wordsearch for 2 MAS that intersect diagonally at A and count the occurrences
///
main :: proc() {
    data := #load("input.txt")
    dim := int(math.sqrt(f32(len(data))))

    start_time := time.now()

    x_inds, a_inds := build_search_indices(data)
    defer delete(x_inds)
    defer delete(a_inds)

    p1 := search_xmas(data, x_inds[:], dim + 1, dim) //+1 on width for the /n
    p2 := search_x_mas(data, a_inds[:], dim + 1, dim)

    duration := time.diff(start_time, time.now())

    fmt.printf("Part 1: %d, Part 2: %d, ms: %f\n", p1, p2, time.duration_milliseconds(duration))
}

build_search_indices :: proc(data: []u8) -> ([dynamic]int, [dynamic]int) {
    x_inds: [dynamic]int
    a_inds: [dynamic]int


    for c, i in data {
        if c == 'X' {
            append(&x_inds, i)
        }
        else if c == 'A' {
            append(&a_inds, i)
        }
    }

    return x_inds, a_inds
}

search_xmas :: proc(data: []u8, x_inds: []int, width, height: int) -> int {
    target := []u8{'M', 'A', 'S'}
    dirs := [8][2]int{{1,0}, {-1,0}, {0,-1}, {0,1}, {1,-1}, {-1,-1}, {1,1}, {-1,1}}

    count := 0

    for i in x_inds {
        x := i % width
        y := i / width

        for dir in dirs {
           if check_dir(data, target[:], x, y, dir.x, dir.y, width, height) {
                count += 1
            } 
        }
    }

    return count
}

search_x_mas :: proc(data: []u8, a_inds: []int, width, height: int) -> int {
    count := 0

    for i in a_inds {
        x := i % width
        y := i / width

        if (check_dir(data, {'M'}, x, y, -1, -1, width, height) && check_dir(data, {'S'}, x, y, 1, 1, width, height) ||
        check_dir(data, {'S'}, x, y, -1, -1, width, height) && check_dir(data, {'M'}, x, y, 1, 1, width, height)) && 
        (check_dir(data, {'M'}, x, y, 1, -1, width, height) && check_dir(data, {'S'}, x, y, -1, 1, width, height) ||
        check_dir(data, {'S'}, x, y, 1, -1, width, height) && check_dir(data, {'M'}, x, y, -1, 1, width, height)){
            count += 1;
        }
    }

    return count
}

check_dir :: proc(data: []u8, target: []u8, sx, sy, dx, dy, w, h: int) -> bool {
#no_bounds_check {
    for t, n in target {
        x := sx + dx * (n + 1)
        y := sy + dy * (n + 1)
        if x < 0 || y < 0 || y >= h { //Don't need to check right bound as there is a \n there
            return false
        }

        i := y * w + x
        if data[i] != t {
            return false
        }
    }
}

    return true
}
