use std::collections::HashSet;

/// Advent of code - Day 10
///
/// Part 1 - Given a sequence of pipes (horizontal, vertical, corners) navigate a looped path from S to S and find the furthest point
/// Part 2 - Count the number of tiles enclosed in the loop
///
fn main() {
    let now = std::time::Instant::now();
    let input = std::fs::read("input.txt").unwrap();

    let (result_1, result_2) = run(input.as_slice());

    println!(
        "Part 1: {}, Part 2: {}, took {:#?}",
        result_1,
        result_2,
        now.elapsed()
    );
}

/// PT1: Do a graph search (depth first) until we get back to S and then half the path length to find the furthest distance from S
/// PT2: Use knot theory such that looking at the elements to the left if there are and off number then we are inside a loop
///
fn run(data: &[u8]) -> (usize, usize) {
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
    let path = dfs(start_idx, data, width);
    let path_set: HashSet<usize> = HashSet::from_iter(path.iter().cloned());

    //Cout how many  |, J, L (the only types we could cross with a horizontal line), or S (if S is also one of I,J,L) appear to the left of this index
    //and if it is odd then this is in the loop
    //NOTE: Just tried both ways to determine whether S should be included for my input
    let mut num_inside: usize = 0;
    let rows = data.len() / width;
    for y in 0..rows {
        let mut num_to_left: usize = 0;
        for x in 0..width - 1 {
            let i = y * width + x;

            let in_path = path_set.contains(&i);

            if !in_path && num_to_left % 2 > 0 {
                num_inside += 1;
            }

            if in_path && matches!(data[i], b'|' | b'J' | b'L' | b'S') {
                num_to_left += 1;
            }
        }
    }

    (path.len() / 2, num_inside)
}

/// Depth first search but checking for a loop - so start idx is the end idx too
/// Returns the path of the loop
///
fn dfs(start_idx: usize, grid: &[u8], width: usize) -> Vec<usize> {
    let mut visited: HashSet<usize> = HashSet::new();
    let mut path: Vec<usize> = Vec::new();

    let mut open_stack: [usize; 10000] = [0; 10000];
    let mut stack_head: usize = 0;

    //Add the first node to the open set to be explored
    open_stack[stack_head] = start_idx;
    stack_head += 1;

    while stack_head > 0 {
        stack_head -= 1;
        let curr_idx = open_stack[stack_head];

        //Reached the target? It's a loop so we have to check it is in the path
        if path.len() > 1 && curr_idx == start_idx {
            break;
        }

        //If we have explored this then don't bother exploring again
        let new_node = visited.insert(curr_idx);
        if !new_node {
            continue;
        }
        path.push(curr_idx);

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
        if curr_idx % width < width {
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

    path
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
