package main

import "core:time"
import "core:fmt"
import "core:strings"
import "core:os"
import "core:strconv"

/// Day 2
///
/// P1: Check if reports are descending or ascending and that the deltas are within range
/// P2: Same as part 1 but if removing any value results in a "safe" result we allow it
///
main :: proc() {
    start_time := time.now()
    data := os.read_entire_file("input.txt") or_else os.exit(1)
    defer delete(data)
    text := string(data)

    p1 := run_no_tolerance(text)
    p2 := run_single_fail_allowed(text)

    duration := time.diff(start_time, time.now())

    fmt.printf("Part 1: %d, Part 2: %d, ms: %f\n", p1, p2, time.duration_milliseconds(duration))
}

run_no_tolerance :: proc(text: string) -> int {
    num_safe := 0

    t := text
    for line in strings.split_lines_iterator(&t) {
        split := strings.split(line, " ")
        vals := make([]int, len(split))
        defer delete(vals)

        for s, i in split {
            vals[i] = strconv.atoi(s)
        }

        if is_safe(vals[:]) {
            num_safe += 1
        }
    }

    return num_safe
}

run_single_fail_allowed :: proc(text: string) -> int {
    num_safe := 0

    t := text
    for line in strings.split_lines_iterator(&t) {
        split := strings.split(line, " ")
        vals := make([]int, len(split))
        defer delete(vals)

        for s, i in split {
            vals[i] = strconv.atoi(s)
        }

        //Test the full set
        if is_safe(vals[:]) {
            num_safe += 1
            continue
        }

        //Explore all possible permutations with one element removed each time
        //We "remove" by swapping into the 0th element and taking a slice from 1
        for i in 0..<len(vals) {
            tmp := vals[i]
            vals[i] = vals[0]
            vals[0] = tmp
            if is_safe(vals[1:]) {
                num_safe += 1
                break
            }
        }
    }

    return num_safe
}

is_safe :: proc(vals: []int) -> bool {
    prev := vals[0]
    prev_sign: Maybe(int)

    for v in vals[1:] {
        delta := v - prev
        sign_delta := sign(delta)

        if delta == 0 || abs(delta) > 3 || (prev_sign != nil && sign_delta != prev_sign) {
            return false
        }

        prev = v
        prev_sign = sign_delta
    }

    return true
}

sign :: proc(x: int) -> int {
    if x == 0 {
        return 0
    }

    if x > 0 {
        return 1
    }

    return -1
}
