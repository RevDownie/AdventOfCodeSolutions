/// Advent of code - Day 15
///
/// Part 1 - Apply HASH algorithm to strings
/// Part 2 - ???
///
fn main() {
    let now = std::time::Instant::now();
    let input = std::fs::read_to_string("input.txt").unwrap();

    let result_1 = run_hash(input.lines());
    let result_2 = 0;

    println!(
        "Part 1: {}, Part 2: {}, took {:#?}",
        result_1,
        result_2,
        now.elapsed()
    );
}

/// Run our HASH algorithm on all the instruction steps in the input and sum the result
///
fn run_hash(lines: std::str::Lines) -> u32 {
    lines
        .map(|l| l.split(',').map(|s| hash(s.as_bytes())).sum::<u32>())
        .sum()
}

/// Apply the HASH alogrithm which performs 3 operations on each character and sums
///
fn hash(step: &[u8]) -> u32 {
    let mut sum = 0;
    for &c in step {
        sum += c as u32;
        sum *= 17;
        sum %= 256;
    }

    sum
}
