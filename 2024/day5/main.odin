package main

import "core:time"
import "core:fmt"
import "core:strings"
import "core:os"
import "core:strconv"
import "core:sort"


/// Day 5
///
/// P1: Page ordering and return the sum of the middle pages from each correctly ordered "update"
///     - Track the index number of each page in the update and then iterate the rules to determine if they are ordered correct
/// P2: For any incorrect order updates - order them an sum the updated middle. 
///     - Sort based on the rules where the compartor checks if x|y rule exists to sort one way and y|x to sort the other
///
main :: proc() {
    data := #load("input.txt")

    start_time := time.now()

    p1, p2 := check_order(data)

    duration := time.diff(start_time, time.now())

    fmt.printf("Part 1: %d, Part 2: %d, ms: %f\n", p1, p2, time.duration_milliseconds(duration))
}

EmptyVal :: struct {}
rules_set: map[u16]EmptyVal

check_order :: proc(data: []u8) -> (u32, u32) {
    text := string(data)

    updates_index_map: [dynamic][100]u8 //For each update holds the index of each page number (max is 99)
    updates_correct_flags: [dynamic] bool //For each update holds whether the update order is correct
    updates_pages: [dynamic] [dynamic]u8 //For each update holds the page numbers
    defer {
        delete(updates_index_map)
        delete(updates_correct_flags)
        delete(updates_pages)
    }

    orders, _, updates := strings.partition(text, "\n\n")

    for u in strings.split_lines_iterator(&updates) {
        pages := strings.split(u, ",")
        page_nums: [dynamic]u8
        index_map: [100]u8
        for page, i in pages {
            p_num := u8(strconv.atoi(page))
            index_map[p_num] = u8(i) + 1 //Save zero for empty so indices start at 1 - we only care about the order anyway
            append(&page_nums, p_num)
        }

        append(&updates_index_map, index_map)
        append(&updates_correct_flags, true)
        append(&updates_pages, page_nums)
    }

    for o in strings.split_lines_iterator(&orders) {
        l, _, r := strings.partition(o, "|")
        l_num := u8(strconv.atoi(l))
        r_num := u8(strconv.atoi(r))

        rules_set[pack_rule_key(l_num, r_num)] = {}

        for u, i in updates_index_map {
            l_order := u[l_num]
            r_order := u[r_num]

            if l_order > 0 && r_order > 0 && l_order > r_order {
                updates_correct_flags[i] = false
            }
        }
    }

    sum_correct: u32
    sum_incorrect: u32
    for b, i in updates_correct_flags {
        if b == true {
            sum_correct += u32(updates_pages[i][len(updates_pages[i])/2])
        }
        else {
            sort.merge_sort_proc(updates_pages[i][:], sort_cmp)
            sum_incorrect += u32(updates_pages[i][len(updates_pages[i])/2])
        }
    }

    return sum_correct, sum_incorrect
}

/// Pack x | y into a single key to make sorting easier
pack_rule_key :: proc(x, y: u8) -> u16 {
    k: u16
    k |= (u16(x) << 8)
    k |= (u16(y) & 0xFF)
    return k
}

/// If a | b then sort left, if b | a sort right
sort_cmp :: proc(a, b: u8) -> int {
    if pack_rule_key(a, b) in rules_set {
        return -1
    }
    
    if pack_rule_key(b, a) in rules_set { 
        return 1
    }

    return 0;
}
