/// Advent of code - Day 9
///
/// Part 1 - A triangle - find the differences between a sequence of numbers recursively until the difference is zero then extrapolate the next in sequence
/// Part 2 - As part 1 but instead of extrapolating the next number we extrapolate the previous number
///
fn main() {
    let now = std::time::Instant::now();
    let input = std::fs::read_to_string("input.txt").unwrap();

    let (result_1, result_2) = run(input.lines());
    println!(
        "Part 1: {}, Part 2: {}, took {:#?}",
        result_1,
        result_2,
        now.elapsed()
    );
}

/// Given a series of numbers per line
/// Find the differences between each number and then in turn the differences between those differences
/// Do this until the differences are all zero.
/// We then need to extrapolate the initial sequences by 1 successive element and sum and then one previous element and sum
///
fn run(lines: std::str::Lines) -> (i32, i32) {
    let mut sum_1: i32 = 0;
    let mut sum_2: i32 = 0;

    for line in lines {
        let nums: Vec<i32> = line
            .split(' ')
            .map(|unparsed| unparsed.parse::<i32>().unwrap())
            .collect();

        //Guess is it is cheaper to reverse now that to parse all the numbers again
        let nums_rev: Vec<i32> = nums.iter().rev().copied().collect();

        sum_1 += extrapolate_recursively(nums.as_slice());
        sum_2 += extrapolate_recursively(nums_rev.as_slice())
    }

    (sum_1, sum_2)
}

fn extrapolate_recursively(nums: &[i32]) -> i32 {
    if nums.iter().all(|&x| x == 0) {
        return 0;
    }

    return extrapolate_recursively(generate_diffs(nums).as_slice()) + nums[nums.len() - 1];
}

fn generate_diffs(nums: &[i32]) -> Vec<i32> {
    let slice = &nums[..nums.len() - 1];
    slice
        .iter()
        .enumerate()
        .map(|(i, x)| nums[i + 1] - x)
        .collect()
}
