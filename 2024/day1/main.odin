package main

import "core:time"
import "core:fmt"
import "core:sort"
import "core:strings"
import "core:os"
import "core:strconv"

/// Day 1
///
/// P1: Sort the lists and sum the deltas between each pair
/// P2: Count the number of times each A in appears in B and then sum A * count in B
///
main :: proc() {
    start_time := time.now()
    p1, p2 := run()
    duration := time.diff(start_time, time.now())

    fmt.printf("Part 1: %d, Part 2: %d, ms: %f\n", p1, p2, time.duration_milliseconds(duration))
}

run :: proc() -> (int, int) {
    data := os.read_entire_file("input.txt") or_else os.exit(1)
    defer delete(data)

    text := string(data)
    lines := strings.split_lines(text)
    num_lines := len(lines)

    numbers_a := make([]int, num_lines)
    defer delete(numbers_a)
    numbers_b := make([]int, num_lines)
    defer delete(numbers_b)

    count_in_b := make(map[int]int)
    defer delete(count_in_b)

    for line, i in lines {
        a, _, b := strings.partition(line, "   ")
        numbers_a[i] = strconv.atoi(a)
        numbers_b[i] = strconv.atoi(b)
        count_in_b[numbers_b[i]] += 1
    }

    sort.merge_sort(numbers_a[:])
    sort.merge_sort(numbers_b[:])

    sum := 0
    sim := 0
    for i in 0..<num_lines {
        sum += abs(numbers_b[i] - numbers_a[i])
        sim += numbers_a[i] * count_in_b[numbers_a[i]]
    }

    return sum, sim
}
