use std::collections::HashMap;
use std::str;

/// Advent of code - Day 14
///
/// Part 1 - Tilt rocks north until they cannot move and then count the number at each level
/// Part 2 - Tilt in cycles - each cycle tips N,W,S,E run for 1000000000 cycles
///
fn main() {
    let now = std::time::Instant::now();
    let input = std::fs::read("input.txt").unwrap();

    let mut grid_1 = input.clone();
    let cycles_north: [(isize, isize); 1] = [(0, -1)];
    let result_1 = tilt_cycle(&mut grid_1, 1, &cycles_north);

    let cycles_full: [(isize, isize); 4] = [(0, -1), (-1, 0), (0, 1), (1, 0)]; //N,W,S,E
    let result_2 = tilt_cycle(&mut grid_1, 1000000000, &cycles_full);

    println!(
        "Part 1: {}, Part 2: {}, took {:#?}",
        result_1,
        result_2,
        now.elapsed()
    );
}

/// Just a naive simulation of the cycle - tilting as far as we can go in each direction until no rocks move and
/// then moving to the next direction in the cycle.
///
/// For long sycles we find the period after which the cycle repeats which allows us to "skip" forward and shortcut all the cycles
///
/// We then sum the rolling rocks on each row multiplied by the row factor
///
fn tilt_cycle(grid: &mut [u8], num_cycles: usize, cycles: &[(isize, isize)]) -> usize {
    let width = grid.iter().take_while(|&c| *c != b'\n').count();
    let height = grid.len() / width - 1;

    let mut cycle_cache: HashMap<String, usize> = HashMap::new();
    let mut found_period = false;

    let mut cycle_num: usize = 0;
    while cycle_num < num_cycles {
        for dir in cycles {
            loop {
                let mut moved = false;

                for y in 0..height {
                    for x in 0..width {
                        let i = y * (width + 1) + x;
                        if grid[i] == b'O' {
                            let new_x = (x as isize) + dir.0;
                            let new_y = (y as isize) + dir.1;
                            if new_x >= 0 && new_x < width as isize && new_y >= 0 && new_y < height as isize
                            {
                                let new_i = (new_y * (width as isize + 1) + new_x) as usize;
                                if grid[new_i] == b'.' {
                                    grid[i] = b'.';
                                    grid[new_i] = b'O';
                                    moved = true;
                                }
                            }
                        }
                    }
                }

                if !moved {
                    break;
                }
            }
        }

        if !found_period {
            let string = unsafe { str::from_utf8_unchecked(grid) };
            let cache_hit = cycle_cache.get(string);
            if let Some(period_start) = cache_hit {
                let period = cycle_num - period_start;
                cycle_num += ((num_cycles - cycle_num)/period) * period;
                found_period = true;
            } else {
                cycle_cache.insert(string.to_string(), cycle_num);
            }
        }

        cycle_num += 1;
    }

    //Count the rolling rocks on each row - top row multiplied by N, bottom row by 1
    let mut sum: usize = 0;
    for (i, l) in grid.split(|&c| c == b'\n').enumerate() {
        sum += (height - i) * l.iter().filter(|&c| *c == b'O').count();
    }
    sum
}

// fn dump_grid(grid: &[u8], width: usize, height: usize) {
//     for y in 0..height {
//         for x in 0..width {
//             print!("{}", grid[y * (width + 1) + x] as char)
//         }
//         println!();
//     }

//     println!();
// }
