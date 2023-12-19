/// Advent of code - Day 18
///
/// Part 1 - Dig trenches and find the area
/// Part 2 - As part 1 but the colour is encoding the instructions
///
fn main() {
    let now = std::time::Instant::now();
    let input = std::fs::read_to_string("input.txt").unwrap();

    let instructions_1 = parse_instructions_1(input.lines());
    let instructions_2 = parse_instructions_2(input.lines());
    let result_1 = solve(&instructions_1);
    let result_2 = solve(&instructions_2);

    println!(
        "Part 1: {}, Part 2: {}, took {:#?}",
        result_1,
        result_2,
        now.elapsed()
    );
}

struct Instruction {
    dir: u8,
    steps: isize,
}

/// R 6 (#70c710) =  Dir Steps (Colour)
/// We don't need the colour - just ignore
fn parse_instructions_1(lines: std::str::Lines) -> Vec<Instruction> {
    let mut ins = Vec::new();

    for l in lines {
        let bytes = l.as_bytes();
        let steps_end = bytes[2..].iter().take_while(|&c| *c != b' ').count();
        ins.push(Instruction {
            dir: bytes[0],
            steps: l[2..2 + steps_end].parse::<isize>().unwrap(),
        });
    }

    ins
}

/// The instructions are accidentally encoded in the colour
/// #70c710 = R 461937
/// The first 5 hex digits are the steps and the last is the direction
///
fn parse_instructions_2(lines: std::str::Lines) -> Vec<Instruction> {
    let mut ins = Vec::new();

    for l in lines {
        let bytes = l.as_bytes();
        let colour_start = bytes.iter().take_while(|&c| *c != b'#').count() + 1;
        ins.push(Instruction {
            dir: match bytes[colour_start + 5] {
                b'0' => b'R',
                b'1' => b'D',
                b'2' => b'L',
                b'3' => b'U',
                _ => unreachable!(),
            },
            steps: isize::from_str_radix(&l[colour_start..colour_start + 5], 16).unwrap(),
        });
    }

    ins
}

/// Run the instructions to generate the vertex positions and the number of cells inbetween
///
fn calc_verts(instructions: &[Instruction]) -> (Vec<(isize, isize)>, usize) {
    let mut current_vertex = (0, 0);
    let mut num_edge_cells = 0;
    let mut vertices: Vec<(isize, isize)> = Vec::new();

    for Instruction { dir, steps } in instructions {
        let (x, y): (isize, isize) = match dir {
            b'R' => (1, 0),
            b'L' => (-1, 0),
            b'D' => (0, 1),
            b'U' => (0, -1),
            _ => unreachable!(),
        };

        current_vertex = (current_vertex.0 + x * steps, current_vertex.1 + y * steps);
        num_edge_cells += steps;
        vertices.push(current_vertex);
    }

    (vertices, num_edge_cells as usize)
}

/// Shoelace Formula: https://en.wikipedia.org/wiki/Shoelace_formula
/// Calculate the area of a polygon from a number of points
fn calc_shoelace_area(vertices: &[(isize, isize)]) -> usize {
    let n = vertices.len();

    let mut sum = 0;
    for (i, v) in vertices.iter().enumerate() {
        sum += v.0 * vertices[(i + 1) % n].1 - vertices[(i + 1) % n].0 * v.1
    }

    (sum.abs() / 2) as usize
}

/// Pick's Theorem: https://en.wikipedia.org/wiki/Pick%27s_theorem
/// i = A - b / 2 + 1
/// i is the number of points interior to the polygon
/// A is the polygon area
/// b is the number of points in the boundary
fn calc_num_interior(a: usize, b: usize) -> usize {
    a - b / 2 + 1
}

/// Calculate the total number of cells based on boundary and interior
///
fn solve(instructions: &[Instruction]) -> usize {
    let (verts, num_edge_cells) = calc_verts(instructions);
    let area = calc_shoelace_area(&verts);
    let num_interior = calc_num_interior(area, num_edge_cells);
    num_interior + num_edge_cells
}
