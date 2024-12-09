package main

import "core:time"
import "core:fmt"
import "core:strings"
import "core:strconv"
import "core:math"

EmptyVal :: struct {}

/// Day 8
///
/// P1: Count all antinodes - these are locations in line with 2 antenna of the same frequency where one is twice as far aways as the other
/// P2: Like part one but extend the line all the way to the edge rather than just twice as far
///
main :: proc() {
    data := #load("input.txt")
    dim := int(math.sqrt(f32(len(data))))

    start_time := time.now()

    antennas := find_antennas(data)
    defer {
        for a in antennas {
            delete(a)
        }
    }

    p1 := count_unique(antennas[:], data, dim + 1, dim)
    p2 := count_unique_extended(antennas[:], data, dim + 1, dim) //'/n' inflates the width by 1

    duration := time.diff(start_time, time.now())

    fmt.printf("Part 1: %d, Part 2: %d, ms: %f\n", p1, p2, time.duration_milliseconds(duration))
}

find_antennas :: proc(data: []u8) -> [200][dynamic]int {
    antennas: [200][dynamic]int
    for a,i in antennas {
        antennas[i] = make([dynamic]int)
    }

    for d,i in data {
        if d != '.' && d != '\n' {
            append(&antennas[d - '0'], i)
        } 
    }

    return antennas
}

count_unique:: proc(antennas_map: [][dynamic]int, data: []u8, width, height: int) -> int {
    unique_locs: map[u64]EmptyVal
    defer delete(unique_locs)

    for antennas in antennas_map {
        if len(antennas) > 0 {
            //All pair combos
            for i in 0..<len(antennas) {
                for j in i+1..<len(antennas) {
                    //Find the distance between the points and project the line in that length either side e.g O...X...X...O
                    a := antennas[i]
                    b := antennas[j]
                    pos_a := [2]f32{f32(a % width), f32(a / width)}
                    pos_b := [2]f32{f32(b % width), f32(b / width)}
                    mid := midpoint(pos_a, pos_b)
                    delta := pos_b - pos_a

                    node_1 := mid + delta * 1.5
                    node_2 := mid - delta * 1.5

                    if node_1.x >= 0 && node_1.x < f32(width - 1) && node_1.y >= 0 && node_1.y < f32(height) {
                        unique_locs[pack_key(u32(node_1.x), u32(node_1.y))] = {}
                    } 
                    if node_2.x >= 0 && node_2.x < f32(width - 1) && node_2.y >= 0 && node_2.y < f32(height) {
                        unique_locs[pack_key(u32(node_2.x), u32(node_2.y))] = {}
                    }
                }
            }
        }
    }

    return len(unique_locs)
}

count_unique_extended :: proc(antennas_map: [][dynamic]int, data: []u8, width, height: int) -> int {
    unique_locs: map[u64]EmptyVal
    defer delete(unique_locs)

    for antennas in antennas_map {
        if len(antennas) > 0 {
            //All pair combos
            for i in 0..<len(antennas) {
                for j in i+1..<len(antennas) {
                    //Find the distance between the points and project the line in that length either side e.g O...X...X...O
                    a := antennas[i]
                    b := antennas[j]
                    pos_a := [2]f32{f32(a % width), f32(a / width)}
                    pos_b := [2]f32{f32(b % width), f32(b / width)}
                    mid := midpoint(pos_a, pos_b)
                    delta := pos_b - pos_a

                    node_1 := mid + delta * 0.5
                    node_2 := mid - delta * 0.5

                    //Keep going in both directions jumping by delta until we hit the edge
                    for {
                        if node_1.x < 0 || node_1.x >= f32(width - 1) || node_1.y < 0 || node_1.y >= f32(height) {
                            break
                        }
                        unique_locs[pack_key(u32(node_1.x), u32(node_1.y))] = {}
                        node_1 += delta
                    }

                    for {
                        if node_2.x < 0 || node_2.x >= f32(width - 1) || node_2.y < 0 || node_2.y >= f32(height) {
                            break
                        }
                        unique_locs[pack_key(u32(node_2.x), u32(node_2.y))] = {}
                        node_2 -= delta
                    }
                }
            }
        }
    }

    return len(unique_locs)
}

midpoint :: proc(v1: [2]f32, v2: [2]f32) -> [2]f32 {
    mid_x := (v1.x + v2.x) * 0.5
    mid_y := (v1.y + v2.y) * 0.5
    return {mid_x, mid_y}
}

pack_key :: proc(x, y: u32) -> u64 {
    return u64(x) << 32 | u64(y)
}
