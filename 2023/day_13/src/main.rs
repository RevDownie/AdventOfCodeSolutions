struct Pattern {
    row_masks: Vec<u32>,
    col_masks: Vec<u32>,
}

#[derive(PartialEq)]
enum CmpResult {
    Eql,
    Smudged,
    NotEql,
}

/// Advent of code - Day 13
///
/// Part 1 - Find the number of mirrored rows and cols
/// Part 2 - Find the "smudges" that if changed would cause a different reflection
///
fn main() {
    let now = std::time::Instant::now();
    let input = include_str!("input.txt");

    let patterns = input.split("\n\n").map(parse).collect::<Vec<Pattern>>();
    let result_1: usize = patterns.iter().map(|p| run(p, false)).sum();
    let result_2: usize = patterns.iter().map(|p| run(p, true)).sum();

    println!(
        "Part 1: {}, Part 2: {}, took {:#?}",
        result_1,
        result_2,
        now.elapsed()
    );
}

/// Pack the rows and columns into a single int so we can compare rows with a single comparison
///
fn parse(pattern_block: &str) -> Pattern {
    let width = pattern_block.chars().take_while(|&c| c != '\n').count();
    let height = pattern_block.lines().count();

    let mut pattern = Pattern {
        row_masks: Vec::with_capacity(height),
        col_masks: Vec::with_capacity(width),
    };

    for l in pattern_block.lines() {
        let mut packed: u32 = 0;
        for (i, c) in l.chars().enumerate() {
            let r = match c {
                '#' => 1,
                '.' => 0,
                _ => panic!("Unknown symbol"),
            };

            packed |= r << i;
        }

        pattern.row_masks.push(packed);
    }

    for x in 0..width {
        let mut packed: u32 = 0;
        for y in 0..height {
            let c = match pattern_block.as_bytes()[y * (width + 1) + x] {
                b'#' => 1,
                b'.' => 0,
                _ => panic!("Unknown symbol"),
            };

            packed |= c << y;
        }

        pattern.col_masks.push(packed);
    }

    pattern
}

/// Check for rows and columns that are next to each other that match
/// These are potential reflection boundaries. We then work out from there to check that
/// the surrounding rows or columns are reflected
///
/// We pass in the compare function because for part 2 for every pair of rows or columns we check
/// to see if changing a single bit would make a reflection. There needs to be at least one "smudge"
///
fn run(p: &Pattern, smudge_required: bool) -> usize {
    let c = if smudge_required {
        solve_single_dir_smudged(&p.col_masks)
    } else {
        solve_single_dir(&p.col_masks)
    };
    if c > 0 {
        return c;
    }

    let r = if smudge_required {
        solve_single_dir_smudged(&p.row_masks)
    } else {
        solve_single_dir(&p.row_masks)
    };
    r * 100
}

/// Allows us to solve for rows or cols with a single function
/// Counts the number of cols/rows that are left/above the found reflection
///
fn solve_single_dir(masks: &Vec<u32>) -> usize {
    'outer: for c in 0..masks.len() - 1 {
        if masks[c] == masks[c + 1] {
            let m = c.min(masks.len() - 2 - c);
            for i in 0..m {
                if masks[c - (i + 1)] != masks[c + (i + 2)] {
                    continue 'outer;
                }
            }

            return c + 1;
        }
    }

    0
}

/// Allows us to solve for rows or cols with a single function
/// Counts the number of cols/rows that are left/above the found reflection
///
/// This is the smudged version so will consider any row/col where a single change would 
/// allow a reflection
///
fn solve_single_dir_smudged(masks: &Vec<u32>) -> usize {
    'outer: for c in 0..masks.len() - 1 {
        let cmp = compare(masks[c], masks[c + 1]);
        let mut smudged = cmp == CmpResult::Smudged;

        if matches!(cmp, CmpResult::Smudged | CmpResult::Eql) {
            let m = c.min(masks.len() - 2 - c);
            for i in 0..m {
                let cmp = compare(masks[c - (i + 1)], masks[c + (i + 2)]);
                match cmp {
                    CmpResult::NotEql => continue 'outer,
                    CmpResult::Eql => {}
                    CmpResult::Smudged => {
                        if smudged {
                            continue 'outer;
                        } else {
                            smudged = true;
                        }
                    }
                }
            }

            if smudged {
                return c + 1;
            }
        }
    }

    0
}

fn compare(a: u32, b: u32) -> CmpResult {
    if a == b {
        return CmpResult::Eql;
    }

    //Check if number is a Po2 which means a single bit is set
    let val = a ^ b;
    if val & (val - 1) == 0 {
        return CmpResult::Smudged;
    }

    CmpResult::NotEql
}
