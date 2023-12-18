use std::cmp::Ordering;
use std::collections::BinaryHeap;
use std::collections::HashMap;

#[derive(Copy, Clone, Eq, PartialEq)]
struct Node {
    idx: usize,
    cost: usize,
    steps_in_dir: u8,
    from_dir: isize,
}

impl Ord for Node {
    fn cmp(&self, other: &Self) -> Ordering {
        other
            .cost
            .cmp(&self.cost)
            .then_with(|| self.idx.cmp(&other.idx))
    }
}

impl PartialOrd for Node {
    fn partial_cmp(&self, other: &Self) -> Option<Ordering> {
        Some(self.cmp(other))
    }
}

/// Advent of code - Day 17
///
/// Part 1 - Find the path with minimal heat loss
/// Part 2 - ???
///
fn main() {
    let now = std::time::Instant::now();
    let input = std::fs::read("input.txt").unwrap();

    let result_1 = find_path(&input);
    let result_2 = 0;

    println!(
        "Part 1: {}, Part 2: {}, took {:#?}",
        result_1,
        result_2,
        now.elapsed()
    );
}

/// Dijkstra's shortest path to find the path with the lowest heat loss cost
/// We cannot move more than 3 cells in the same direction
/// We cannot move diagnonally
///
fn find_path(grid: &[u8]) -> usize {
    let width = grid.iter().take_while(|&c| *c != b'\n').count() as isize + 1;
    let height = (grid.len() as isize) / width;
    let end_idx: usize = grid.len() - 2;

    let mut open_queue = BinaryHeap::new();
    let mut lowest_costs_to_node: HashMap<(usize, isize, u8), usize> = HashMap::new();

    //Add the first node to the open set to be explored
    open_queue.push(Node {
        idx: 0,
        cost: 0,
        steps_in_dir: 0,
        from_dir: 0,
    });
    lowest_costs_to_node.insert((0, 1, 0), 0);
    lowest_costs_to_node.insert((0, width, 0), 0);

    while let Some(curr_node) = open_queue.pop() {
        //Reached the target?
        if curr_node.idx == end_idx {
            return curr_node.cost;
        }

        // Check if we have already found a cheaper way
        let key = (curr_node.idx, curr_node.from_dir, curr_node.steps_in_dir);
        if curr_node.cost > *lowest_costs_to_node.get(&key).unwrap_or(&usize::MAX) {
            continue;
        }

        //Find valid adjacent nodes that have a lower cost
        let steps = [-1, 1, width, -width];
        for s in steps {
            let next_idx = (curr_node.idx as isize) + s;

            //Don't backtrack
            if s == -curr_node.from_dir {
                continue;
            }

            //Check in bounds
            let (x, y) = (next_idx % width, next_idx / width);
            if x < 0 || x >= (width - 1) || y < 0 || y >= height {
                continue;
            }

            //Check length limit in same dir is not exceeded
            let next_steps_in_dir = if s == curr_node.from_dir {
                curr_node.steps_in_dir + 1
            } else {
                1
            };
            if next_steps_in_dir > 3 {
                continue;
            }

            //Check to make sure there isn't already a cheaper route to this node
            let next_cost = curr_node.cost + (grid[next_idx as usize] - b'0') as usize;
            let next_key = (next_idx as usize, s, next_steps_in_dir);
            if next_cost < *lowest_costs_to_node.get(&next_key).unwrap_or(&usize::MAX) {
                lowest_costs_to_node.insert(next_key, next_cost);
                open_queue.push(Node {
                    idx: next_idx as usize,
                    cost: next_cost,
                    steps_in_dir: next_steps_in_dir,
                    from_dir: s,
                });
            }
        }
    }

    unreachable!()
}
