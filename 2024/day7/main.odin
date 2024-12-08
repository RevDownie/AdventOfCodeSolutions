package main

import "core:time"
import "core:fmt"
import "core:strings"
import "core:strconv"
import "core:math"


/// Day 7
///
/// P1: Find the lines where adding + or * can balance the equation
///     - Working backwards allows us to filter out multiplications
/// P2: Same as P1 but adding a concat operator "||"
///
main :: proc() {
    data := #load("input.txt")

    start_time := time.now()

    p1, p2 := count_valid(data)

    duration := time.diff(start_time, time.now())

    fmt.printf("Part 1: %d, Part 2: %d, ms: %f\n", p1, p2, time.duration_milliseconds(duration))
}

count_valid :: proc(data: []u8) -> (int, int) {
    text := string(data)

    sum1 := 0
    sum2 := 0

    for line in strings.split_lines_iterator(&text) {
        target_s, _, vals_s := strings.partition(line, ":")
        target := strconv.atoi(target_s)
        vals_s_split := strings.split(vals_s, " ")
        vals := make([]int, len(vals_s_split) - 1) //Extra empty ""
        defer delete(vals)

        for v,i in vals_s_split[1:] {
            vals[i] = strconv.atoi(v)
        }

        if is_valid(target, vals, false) {
            sum1 += target
        }

        if is_valid(target, vals, true) {
            sum2 += target
        }
    }

    return sum1, sum2
}

/// Back propagate as that allows us to use mod to determine if a multiply path is worth exploring
is_valid :: proc(current_total: int, vals: []int, include_concat: bool) -> bool {
    len_vals := len(vals)
    if len_vals == 1 {
        return current_total == vals[0]
    }

    last := vals[len_vals - 1]
    remaining_vals := vals[:len_vals-1]

    if current_total % last == 0 && is_valid(current_total / last, remaining_vals, include_concat) {
        return true
    }
    
    if current_total > last && is_valid(current_total - last, remaining_vals, include_concat) {
        return true
    }

    if include_concat {
        last_len := int(math.log10(f32(last))) + 1
        mag := int(math.pow10(f32(last_len)))
        total_len := int(math.log10(f32(current_total))) + 1
        if total_len > last_len && last == (current_total % mag) && is_valid(current_total / mag, remaining_vals, include_concat) {
            return true
        }
    }

    return false
}
