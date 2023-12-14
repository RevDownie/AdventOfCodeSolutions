struct Pattern {
    row_masks: Vec<u32>,
    col_masks: Vec<u32>,
}

/// Advent of code - Day 13
///
/// Part 1 - Find the number of mirrored rows and cols
/// Part 2 - ???
///
fn main() {
    let now = std::time::Instant::now();
    let input = include_str!("input.txt");

    let result_1: usize = input.split("\n\n").map(|p| run(&parse(p))).sum();
    let result_2 = 0;

    println!(
        "Part 1: {}, Part 2: {}, took {:#?}",
        result_1,
        result_2,
        now.elapsed()
    );
}

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
        // println!("{:#016b}", packed);
        pattern.col_masks.push(packed);
    }

    pattern
}

fn run(p: &Pattern) -> usize {
    'outer: for c in 0..p.col_masks.len() - 1 {
        if p.col_masks[c] == p.col_masks[c + 1] {
            let rng = c.min(p.col_masks.len() - 2 - c) ;
            println!("Check col rng: {}|{}, {} => {}", c, c+1, p.col_masks.len(), rng);
            for i in 0..rng {
                println!("{},{}", c-(i+1), c+(i+2));
                if p.col_masks[c-(i+1)] != p.col_masks[c+(i+2)] {
                    continue 'outer;
                }
            }

            println!("Mirror col: {}", c + 1);
            return c + 1;
        }
    }

    'outer: for r in 0..p.row_masks.len() - 1 {
        if p.row_masks[r] == p.row_masks[r + 1] {
            let rng = r.min(p.row_masks.len() - 2 - r);
            for i in 0..rng {
                if p.row_masks[r-(i+1)] != p.row_masks[r+(i+2)] {
                    continue 'outer;
                }
            }
            println!("Mirror row: {}", r + 1);
            return (r + 1) * 100;
        }
    }

    0
}
