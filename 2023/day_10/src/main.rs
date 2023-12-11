use std::collections::HashSet;

/// Advent of code - Day 10
///
/// Part 1 - Given a sequence of pipes (horizontal, vertical, corners) navigate a looped path from S to S and find the furthest point
/// Part 2 - ???
///
fn main() {
    let now = std::time::Instant::now();
    let input = std::fs::read("input.txt").unwrap();

    let result_1 = part_1(input.as_slice());
    let result_2 = 0;

    println!(
        "Part 1: {}, Part 2: {}, took {:#?}",
        result_1,
        result_2,
        now.elapsed()
    );
}

/// Do an graph search (depth first) until we get back to S and then half the path length
///
fn part_1(data: &[u8]) -> usize {
    //Find the width of the grid
    let mut width: usize = 0;
    while data[width] != b'\n' {
        width += 1;
    }
    width += 1; //Account for the newline

    //Find the start node
    let mut start_idx: usize = 0;
    while data[start_idx] != b'S' {
        start_idx += 1;
    }

    //Start at S and find our way back to S
    let path_len = dfs(start_idx, data, width);

    return path_len / 2;
}

/// Depth first search but checking for a loop - so start idx is the end idx too
///
fn dfs(start_idx: usize, grid: &[u8], width: usize) -> usize {
    let mut visited: HashSet<usize> = HashSet::new();
    let mut path_len: usize = 0;

    let mut open_stack: [usize; 10000] = [0; 10000];
    let mut stack_head: usize = 0;

    //Add the first node to the open set to be explored
    open_stack[stack_head] = start_idx;
    stack_head += 1;

    while stack_head > 0 {
        stack_head -= 1;
        let curr_idx = open_stack[stack_head];

        //Reached the target? It's a loop so we have to check it is in the path
        if path_len > 1 && curr_idx == start_idx {
            return path_len;
        }

        //If we have explored this then don't bother exploring again
        let new_node = visited.insert(curr_idx);
        if !new_node {
            continue;
        }
        path_len += 1;

        //Find valid adjacent nodes
        //-Left
        if curr_idx % width > 0 {
            let next_idx = curr_idx - 1;
            if is_valid_hor(grid[next_idx], grid[curr_idx]) {
                open_stack[stack_head] = next_idx;
                stack_head += 1;
            }
        }

        //-Right
        if curr_idx % width <= width - 1 {
            let next_idx = curr_idx + 1;
            if is_valid_hor(grid[curr_idx], grid[next_idx]) {
                open_stack[stack_head] = next_idx;
                stack_head += 1;
            }
        }

        //-Up
        if curr_idx > width {
            let next_idx = curr_idx - width;
            if is_valid_ver(grid[next_idx], grid[curr_idx]) {
                open_stack[stack_head] = next_idx;
                stack_head += 1;
            }
        }

        //-Down
        if curr_idx + width < grid.len() {
            let next_idx = curr_idx + width;
            if is_valid_ver(grid[curr_idx], grid[next_idx]) {
                open_stack[stack_head] = next_idx;
                stack_head += 1;
            }
        }
    }

    return 0;
}

//Encoding all valid connections
const H_H: u16 = (b'-' as u16) << 8 | (b'-' as u16);
const H_7: u16 = (b'-' as u16) << 8 | (b'7' as u16);
const H_J: u16 = (b'-' as u16) << 8 | (b'J' as u16);
const F_H: u16 = (b'F' as u16) << 8 | (b'-' as u16);
const L_H: u16 = (b'L' as u16) << 8 | (b'-' as u16);
const F_7: u16 = (b'F' as u16) << 8 | (b'7' as u16);
const F_J: u16 = (b'F' as u16) << 8 | (b'J' as u16);
const L_7: u16 = (b'L' as u16) << 8 | (b'7' as u16);
const L_J: u16 = (b'L' as u16) << 8 | (b'J' as u16);
const U_U: u16 = (b'|' as u16) << 8 | (b'|' as u16);
const U_J: u16 = (b'|' as u16) << 8 | (b'J' as u16);
const U_L: u16 = (b'|' as u16) << 8 | (b'L' as u16);
const S7_U: u16 = (b'7' as u16) << 8 | (b'|' as u16);
const F_U: u16 = (b'F' as u16) << 8 | (b'|' as u16);
const F_L: u16 = (b'F' as u16) << 8 | (b'L' as u16);
const S7_L: u16 = (b'7' as u16) << 8 | (b'L' as u16);
const S7_J: u16 = (b'7' as u16) << 8 | (b'J' as u16);

fn is_valid_hor(a: u8, b: u8) -> bool {
    if a == b'S' && b != b'.' {
        return true;
    }

    let x: u16 = (a as u16) << 8 | (b as u16);
    matches!(x, H_H | H_7 | H_J | F_H | L_H | F_7 | F_J | L_7 | L_J)
}

fn is_valid_ver(a: u8, b: u8) -> bool {
    if a == b'S' && b != b'.' {
        return true;
    }

    //Up on left, down on right
    let x: u16 = (a as u16) << 8 | (b as u16);
    matches!(x, U_U | U_J | U_L | S7_U | F_U | F_L | F_J | S7_L | S7_J)
}
