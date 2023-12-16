struct Beam {
    head_idx: isize,
    dir: isize,
}

/// Advent of code - Day 16
///
/// Part 1 - Lasers bouncing and splitting around a grid
/// Part 2 - ???
///
fn main() {
    let now = std::time::Instant::now();
    let input = std::fs::read("input.txt").unwrap();

    let result_1 = simulate(&input);
    let result_2 = 0;

    println!(
        "Part 1: {}, Part 2: {}, took {:#?}",
        result_1,
        result_2,
        now.elapsed()
    );
}

/// Bounce and split lasers based on symbols and track the cells in the grid that
/// they interact with. Then sum the number of cells
///
fn simulate(grid: &[u8]) -> usize {
    let width = grid.iter().take_while(|&c| *c != b'\n').count() as isize + 1;
    let height = (grid.len() as isize) / width;

    let mut beams: Vec<Beam> = Vec::new();
    beams.push(Beam {
        head_idx: -1,
        dir: 1,
    });

    let mut energised = vec![false; (width * height) as usize];
    let mut num_energised: usize = 0;

    while !beams.is_empty() {
        let mut beam_idx: usize = 0;
        while beam_idx < beams.len() {
            let b = &mut beams[beam_idx];
            let new_head_idx = b.head_idx + b.dir;
            let new_head_x = new_head_idx % width;
            let new_head_y = new_head_idx / width;

            //If the beam goes out of bounds we destroy it
            if new_head_x < 0 || new_head_x >= (width - 1) || new_head_y < 0 || new_head_y >= height
            {
                _ = beams.swap_remove(beam_idx);
                continue;
            }

            let already_energised = energised[new_head_idx as usize];
            if !already_energised {
                energised[new_head_idx as usize] = true;
                num_energised += 1;
            }

            match grid[new_head_idx as usize] {
                b'.' => {}                                                   //Just continue
                b'\\' => b.dir = determine_bounce_backslash(b.dir, width),   //Reflect
                b'/' => b.dir = determine_bounce_forwardslash(b.dir, width), //Reflect
                b'-' => {
                    if already_energised {
                        //Avoid this beam getting stuck in a loop
                        _ = beams.swap_remove(beam_idx);
                        continue;
                    }

                    //Try split
                    if let Some((a, b)) = determine_split_horizontal(b.dir, new_head_idx, width) {
                        _ = beams.swap_remove(beam_idx);
                        beams.push(a);
                        beams.push(b);
                        continue;
                    }
                }
                b'|' => {
                    if already_energised {
                        //Avoid this beam getting stuck in a loop
                        _ = beams.swap_remove(beam_idx);
                        continue;
                    }
                    //Try split
                    if let Some((a, b)) = determine_split_vertical(b.dir, new_head_idx, width) {
                        _ = beams.swap_remove(beam_idx);
                        beams.push(a);
                        beams.push(b);
                        continue;
                    }
                }
                _ => panic!("Unknown symbol"),
            }

            b.head_idx = new_head_idx;
            beam_idx += 1;
        }
    }

    num_energised
}

fn dump_grid(energised: &[bool], width: isize, height: isize) {
    let h = height as usize;
    let w = (width - 1) as usize;
    for y in 0..h {
        for x in 0..w {
            print!("{}", if energised[y * (w + 1) + x] { '#' } else { '.' });
        }
        println!();
    }
    println!();
}

/// If beam comes from the left we reflect down
/// If beam comes from the right we reflect up
/// If beam comes from down we reflect left
/// If beam comes from up we reflect right
///
fn determine_bounce_backslash(dir: isize, width: isize) -> isize {
    if dir == 1 {
        return width;
    };
    if dir == -1 {
        return -width;
    };
    if dir == width {
        return 1;
    };
    if dir == -width {
        return -1;
    };

    unreachable!()
}

/// If beam comes from the left we reflect up
/// If beam comes from the right we reflect down
/// If beam comes from down we reflect right
/// If beam comes from up we reflect left
///
fn determine_bounce_forwardslash(dir: isize, width: isize) -> isize {
    if dir == 1 {
        return -width;
    };
    if dir == -1 {
        return width;
    };
    if dir == width {
        return -1;
    };
    if dir == -width {
        return 1;
    };

    unreachable!()
}

/// If beam comes from left or right then do nothing
/// If beam comes from top or bottom then split
fn determine_split_horizontal(dir: isize, head_idx: isize, width: isize) -> Option<(Beam, Beam)> {
    let abs = dir.abs();
    if abs == 1 {
        return None;
    }

    if abs == width {
        return Some((
            Beam {
                head_idx: head_idx,
                dir: -1,
            },
            Beam {
                head_idx: head_idx,
                dir: 1,
            },
        ));
    }

    unreachable!()
}

/// If beam comes from left or right then split
/// If beam comes from top or bottom then do nothing
fn determine_split_vertical(dir: isize, head_idx: isize, width: isize) -> Option<(Beam, Beam)> {
    let abs = dir.abs();
    if abs == width {
        return None;
    }

    if abs == 1 {
        return Some((
            Beam {
                head_idx: head_idx,
                dir: -width,
            },
            Beam {
                head_idx: head_idx,
                dir: width,
            },
        ));
    }

    unreachable!()
}
