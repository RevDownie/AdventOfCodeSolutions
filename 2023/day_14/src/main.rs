/// Advent of code - Day 14
///
/// Part 1 - Tilt rocks north until they cannot move and then count the number at each level
/// Part 2 - ???
///
fn main() {
    let now = std::time::Instant::now();
    let input = std::fs::read("input.txt").unwrap();
    let mut grid_1 = input.clone();
    let result_1 = tilt_north(&mut grid_1);
    let result_2 = 0; //usize = patterns.iter().map(|p| run(p, true)).sum();

    println!(
        "Part 1: {}, Part 2: {}, took {:#?}",
        result_1,
        result_2,
        now.elapsed()
    );
}

fn tilt_north(grid: &mut [u8]) -> usize {
    let width = grid.iter().take_while(|&c| *c != b'\n').count();
    let height = grid.len()/width - 1;
    println!("{height}");

    dump_grid(grid, width, height);

    loop {
        let mut moved = false;

        for y in 1..height {
            for x in 0..width {
                let i = y * (width + 1) + x;
                if grid[i] == b'O' {
                    let up = (y - 1) * (width + 1) + x;
                    if grid[up] == b'.' {
                        //Move it up until we hit the ceiling or a '#'
                        grid[i] = b'.';
                        grid[up] = b'O';
                        moved = true;
                    }
                }
            }
        }

        // dump_grid(grid, width, height);
        if !moved {
            break;
        }
    }

    dump_grid(grid, width, height);

    let mut sum: usize = 0;
    for (i, l) in grid.split(|&c| c == b'\n').enumerate() {
        sum += (height - i) * l.iter().filter(|&c| *c == b'O').count();
    }
    sum
}

fn dump_grid(grid: &[u8], width: usize, height: usize) {
    for y in 0..height {
        for x in 0..width {
            print!("{}", grid[y * (width + 1) + x] as char)
        }
        println!();
    }

    println!();
}
