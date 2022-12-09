/// Knots start at the same location
/// Parse the instructions for how the head moves "R 5", "U 2", etc
/// Move head to the location and have the below knots move to within one and mark any travelled positions as visited
/// knot won't move if it is within 1 even diagnonally but if it does move won't ever rest diagonally
///     - so if it is in a different row or col it's first move will be diagonally
///
fn run_simulation(lines: std::str::Lines, num_knots: usize) -> usize {
    let mut knot_positions: Vec<(isize, isize)> = Vec::with_capacity(num_knots);
    knot_positions.resize(num_knots, (0, 0));

    let mut visited_set: std::collections::HashSet<(isize, isize)> =
        std::collections::HashSet::new();

    for line in lines {
        let (dir, step) = line.split_once(' ').unwrap();
        let step = step.parse::<u32>().unwrap();

        let v = match dir {
            "U" => (0, 1),
            "D" => (0, -1),
            "R" => (1, 0),
            "L" => (-1, 0),
            _ => unreachable!(),
        };

        for _ in 0..step {
            //Move head to the next location
            knot_positions[0].0 += v.0;
            knot_positions[0].1 += v.1;

            //Move all the knots below the head
            for k in 1..num_knots {
                //Check if we need to move the tail
                let (x_dist, y_dist) = (
                    knot_positions[k - 1].0 - knot_positions[k].0,
                    knot_positions[k - 1].1 - knot_positions[k].1,
                );
                if x_dist.abs() <= 1 && y_dist.abs() <= 1 {
                    continue;
                }

                //Move the knot
                knot_positions[k].0 += x_dist.signum();
                knot_positions[k].1 += y_dist.signum();
            }

            //Record any unique tail positions
            visited_set.insert(knot_positions[num_knots - 1]);
        }
    }
    visited_set.len()
}

/// Advent of code - Day 9
///
/// NOTE: Not in Zig because I couldn't get Zig hash set to return the correct count wither with @vector2 or custom packed u32 key
///
/// Part 1 - Knots in a rope. Keep the tail next to the head and count visited spaces
/// Part 2 - The rope is now 10 in length
///
fn main() {
    let now = std::time::Instant::now();
    let input = std::fs::read_to_string("input.txt").unwrap();

    let result_1 = run_simulation(input.lines(), 2);
    let result_2 = run_simulation(input.lines(), 10);
    println!(
        "Part 1: {}, Part 2: {}, took {:#?}",
        result_1,
        result_2,
        now.elapsed()
    );
}
