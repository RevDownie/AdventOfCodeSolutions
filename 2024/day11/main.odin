package main

import "core:time"
import "core:fmt"
import "core:strings"
import "core:strconv"
import "core:math"

/// Day 11
///
/// P1: Stones that change and split each blink - count number of stones after 25 blinks
///     - Trick is that the order doesn't matter so rather than running the simulation on each number you can group 
///       into batches by storing the number of each and calculate once per number (e.g. all 2048 split into 20 and 48)
/// P2: Same but 75 blinks
///
main :: proc() {
    data := #load("input.txt")

    start_time := time.now()

    p1, p2 := run_blink_sim(data)

    duration := time.diff(start_time, time.now())

    fmt.printf("Part 1: %d, Part 2: %d, ms: %f\n", p1, p2, time.duration_milliseconds(duration))
}

run_blink_sim :: proc(data: []u8) -> (u64, u64) {
    num_map: map[u64]u64
    defer delete(num_map)
    num_map_cp: map[u64]u64
    defer delete(num_map_cp)

    //Build a map with the count of all the initial numbers
    text := string(data)
    for n in strings.split_iterator(&text, " ") {
        num_map[u64(strconv.atoi(n))] += 1
    }

    //Perform 25 "blinks"
    for i in 0..<25{
        blink_all(&num_map, &num_map_cp)
    }

    count_25 := u64(0)
    for key in num_map {
        count_25 += num_map[key]
    }

    //Perform 75 "blinks" (50 more)
    for i in 0..<50{
        blink_all(&num_map, &num_map_cp)
    }

    count_75 := u64(0)
    for key in num_map {
        count_75 += num_map[key]
    }

    return count_25, count_75
}

blink_all :: proc(num_map, num_map_cp: ^map[u64]u64) {
    //Copy so we don't modify as we are iterating
    map_copy(num_map, num_map_cp)

    for key, val in num_map_cp {
        if val > 0 {
            //Blink this stone
            num_new, new := blink(key)

            //Remove the stones that have been converted
            num_map[key] -= val

            //Add the new stones
            for j in 0..<num_new {
                num_map[new[j]] += val
            }
        }
    }
}

/// Returns the number of new stones (at max 2) and the new values of those stones
blink :: proc(val: u64) -> (int, [2]u64) {
    if val == 0 {
        return 1, {1, 0}
    }

    //Even number of digits are split into two
    num_digits := u64(math.log10(f64(val))) + 1
    if num_digits % 2 == 0 {
        div := u64(math.pow10(f64(num_digits/2)))
        return 2, {val / div, val % div}
    }

    return 1, {val * 2024, 0}
}

map_copy :: proc(src: ^map[u64]u64, dst: ^map[u64]u64) {
    clear(dst)
    reserve(dst, len(src))

    for k,v in src {
        if v > 0 {
            dst[k] = v
        }
    }
}
