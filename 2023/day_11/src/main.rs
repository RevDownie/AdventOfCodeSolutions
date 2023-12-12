/// Advent of code - Day 11
///
/// Part 1 - Sum the shortest dists between galaxies that are also expanding away
/// Part 2 - As part 1 but the expansion is 1000000
///
fn main() {
    let now = std::time::Instant::now();
    let input = std::fs::read("input.txt").unwrap();

    let result_1 = run(input.as_slice(), 1);
    let result_2 = run(input.as_slice(), 999999);

    println!(
        "Part 1: {}, Part 2: {}, took {:#?}",
        result_1,
        result_2,
        now.elapsed()
    );
}

/// Galaxies are represented by #
/// Find the X,Y of all galaxies
/// Find the rows and columns that have no galaxies
/// Any galaxies that are to the right or bottom of an empty row or col need to expand by the factor
/// Find the manhattan distance between all pairs
/// Sum and return
///
fn run(data: &[u8], exp_factor: i64) -> i64 {
    //Find the width of the grid
    let mut width: usize = 0;
    while data[width] != b'\n' {
        width += 1;
    }
    width += 1; //Account for the newline

    //Find the X,Y of all galaxies
    let mut galaxy_pos: Vec<(i64, i64)> = data
        .iter()
        .enumerate()
        .filter(|(_, &x)| x == b'#')
        .map(|(i, _)| ((i % width) as i64, (i / width) as i64))
        .collect();

    //Expand cols
    galaxy_pos.sort_by_key(|xy| xy.0);
    let mut exp_x: i64 = 0;
    for i in 1..galaxy_pos.len() {
        exp_x += (galaxy_pos[i].0 + exp_x - galaxy_pos[i-1].0 - 1).max(0) * exp_factor;
        galaxy_pos[i].0 += exp_x;
    }

    //Expand rows
    galaxy_pos.sort_by_key(|xy| xy.1);
    let mut exp_y: i64 = 0;
    for i in 1..galaxy_pos.len() {
        exp_y += (galaxy_pos[i].1 + exp_y - galaxy_pos[i-1].1 - 1).max(0) * exp_factor;
        galaxy_pos[i].1 += exp_y;
    }

    //Find the shortest distance between each pair of galaxies and sum
    let mut sum: i64 = 0;
    for i in 0..galaxy_pos.len() {
        for j in (i+1)..galaxy_pos.len() {
            sum += manhattan_dist(galaxy_pos[i], galaxy_pos[j]);
        }
    }

    sum
}

fn manhattan_dist(a: (i64, i64), b: (i64, i64)) -> i64 {
    (a.0 - b.0).abs() + (a.1 - b.1).abs()
}
