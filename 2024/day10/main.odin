package main

import "core:time"
import "core:fmt"
import "core:math"

/// Day 10
///
/// P1: Count all unique peaks (trailheads) that are reachable from paths starting at 0 and ending at 9 with an increase in height of 1 each step
/// P2: Count all unique trails instead
///
main :: proc() {
    data := #load("input.txt")
    dim := int(math.sqrt(f32(len(data))))

    start_time := time.now()

    p1, p2 := count_unique_trails(data, dim + 1, dim) //Width padded with '\n'

    duration := time.diff(start_time, time.now())

    fmt.printf("Part 1: %d, Part 2: %d, ms: %f\n", p1, p2, time.duration_milliseconds(duration))
}

count_unique_trails :: proc(data: []u8, width, height: int) -> (int, int){
    node_count_map := make([]int, len(data))
    for i in 0..<len(node_count_map) {
        node_count_map[i] = -1
    }
    defer delete(node_count_map)

    peak_map := make([]bool, len(data))
    defer delete(peak_map)

    num_trailheads := 0
    num_unique_trails := 0
    for d,i in data {
        if d == '0' {
            //Found a starting point to explore
            num_trailheads += find_trailheads(data, width, height, i % width, i / width, '0', peak_map[:])
            num_unique_trails += find_trails(data, width, height, i % width, i / width, '0', node_count_map[:])
        }

        //Reset the peaks visited from this starting point
        for i in 0..<len(peak_map) {
            peak_map[i] = false
        }
    }
    return num_trailheads, num_unique_trails
}

//Depth first search, looking for peaks and then counting the number of unique ones found from this x,y
find_trailheads :: proc(data: []u8, width, height, x, y: int, looking_for: u8, peak_map: []bool) -> int {
    idx := y * width + x

    if data[idx] != looking_for {
        //Not a path to explore
        return 0
    }

    if looking_for == '9' && peak_map[idx] == false {
        //We've found the destination - mark as explored
        peak_map[idx] = true
        return 1
    }

    //Explore the cardinal axes
    count := 0
    if x - 1 >= 0 {
        count += find_trailheads(data, width, height, x-1, y, looking_for + 1, peak_map)
    }
    if x + 1 < width-1 {
        count += find_trailheads(data, width, height, x+1, y, looking_for + 1, peak_map)
    }
    if y - 1 >= 0 {
        count += find_trailheads(data, width, height, x, y-1, looking_for + 1, peak_map)
    }
    if y + 1 < height {
        count += find_trailheads(data, width, height, x, y+1, looking_for + 1, peak_map)
    }

    return count
}

//Depth first search, storing the trail count for each node so we don't have to explore each time
find_trails :: proc(data: []u8, width, height, x, y: int, looking_for: u8, node_count_map: []int) -> int {
    idx := y * width + x

    if data[idx] != looking_for {
        //Not a path to explore
        return 0
    }

    if node_count_map[idx] >= 0 {
        //We've explored this node and have the number of trails already
        return node_count_map[idx]
    }

    if looking_for == '9' {
        //We've found the destination
        node_count_map[idx] = 1
        return 1
    }

    //Explore the cardinal axes
    count := 0
    if x - 1 >= 0 {
        count += find_trails(data, width, height, x-1, y, looking_for + 1, node_count_map)
    }
    if x + 1 < width-1 {
        count += find_trails(data, width, height, x+1, y, looking_for + 1, node_count_map)
    }
    if y - 1 >= 0 {
        count += find_trails(data, width, height, x, y-1, looking_for + 1, node_count_map)
    }
    if y + 1 < height {
        count += find_trails(data, width, height, x, y+1, looking_for + 1, node_count_map)
    }

    node_count_map[idx] = count
    return count
}
