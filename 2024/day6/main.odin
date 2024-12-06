package main

import "core:time"
import "core:fmt"
import "core:math"

EmptyVal :: struct {}

/// Day 6
///
/// P1: Walk until you reach an obstacle, turn right and count unique cells until exiting the grid
/// P2: Place a new obstruction that causes the guard to loop and count the number of places we can place such an obstacle to force a loop
///
main :: proc() {
    data := #load("input.txt")
    dim := int(math.sqrt(f32(len(data))))

    start_time := time.now()

    //Find start pos - puzzle isn't clear if the guard can start facing any direction but up
    start_idx := 0
    for b,i in data {
        if b == '^' {
            start_idx = i
            break
        }
    }

    visited_nodes := grid_walk(start_idx, data, dim + 1, dim) //Data has '/n's that pad the width
    defer delete(visited_nodes)

    p1 := len(visited_nodes)
    p2 := force_loops(visited_nodes, start_idx, data, dim + 1, dim)

    duration := time.diff(start_time, time.now())

    fmt.printf("Part 1: %d, Part 2: %d, ms: %f\n", p1, p2, time.duration_milliseconds(duration))
}

grid_walk :: proc(start_idx: int, data: []u8, width, height: int) -> map[int]EmptyVal {
    //Track visited nodes
    visited_nodes: map[int]EmptyVal
    visited_nodes[start_idx] = {}

    dir := [2]int{0, -1}
    pos := [2]int{start_idx % width, start_idx / width}

    for {
        //Walk forward until we hit # and then turn right
        next_pos := pos + dir

        //Check: Walked off grid
        if next_pos.x < 0 || next_pos.x >= (width-1) || next_pos.y < 0 || next_pos.y >= height {
            break
        }

        i := next_pos.y * width + next_pos.x

        //Check: Hit an obstacle - rotate 90 clockwise
        if data[i] == '#' {
            dir = {-dir.y, dir.x}
        } else {
            pos = next_pos
            visited_nodes[i] = {}
        }
    }

    //Unique nodes visited
    return visited_nodes
}

force_loops :: proc(visited_nodes: map[int]EmptyVal, start_idx: int, data: []u8, width, height: int) -> int {
    //Track visited nodes with the direction from which they were entered so we can detect a loop
    visited_nodes_with_dir: map[u32]EmptyVal
    defer delete(visited_nodes_with_dir)

    forced_loop_count := 0

    //Replace each visited node with an obstacle to see if that forces a loop
    for visited_i, _ in visited_nodes {
        dir := [2]int{0, -1}
        pos := [2]int{start_idx % width, start_idx / width}
        clear(&visited_nodes_with_dir)

        for {
            //Walk forward until we hit # and then turn right
            next_pos := pos + dir

            //Check: Walked off grid
            if next_pos.x < 0 || next_pos.x >= (width-1) || next_pos.y < 0 || next_pos.y >= height {
                break
            }

            i := next_pos.y * width + next_pos.x

            //Check: Hit an obstacle (where we also place a new obstacle to try and force a loop) - rotate 90 clockwise
            if i == visited_i || data[i] == '#' {
                dir = {-dir.y, dir.x}
            } else {
                //If we reach a node we have already visited from this direction then we are in a loop
                key := pack_key(i, dir.x, dir.y)
                if key in visited_nodes_with_dir {
                    forced_loop_count += 1
                    break
                }

                pos = next_pos
                visited_nodes_with_dir[key] = {}
            }
        }
    }

    return forced_loop_count
}

pack_key :: proc (index, x, y: int) -> u32 {
    return u32(index) | (u32(x+1) << 16) | (u32(y+1) << 18)
}
