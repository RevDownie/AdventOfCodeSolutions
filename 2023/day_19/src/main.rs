use std::collections::HashMap;

#[derive(Debug)]
struct Workflow {
    conditionals: [Conditional; 4],
    num_conditionals: usize,
    else_dest: u32,
}

impl Workflow {
    fn run(&self, vals: &[u16]) -> u32 {
        for c in &self.conditionals[0..self.num_conditionals] {
            let val = vals[c.var_idx];
            if val > c.thresholds.0 && val < c.thresholds.1 {
                return c.dest;
            }
        }

        //Fallback
        self.else_dest
    }
}

#[derive(Copy, Clone, Debug)]
struct Conditional {
    var_idx: usize,
    thresholds: (u16, u16),
    dest: u32,
}

/// Advent of code - Day 19
///
/// Part 1 - Workflows to accept or reject a part
/// Part 2 - ???
///
fn main() {
    let now = std::time::Instant::now();
    let input = std::fs::read_to_string("input.txt").unwrap();

    let (w, v) = input.split_once("\n\n").unwrap();
    let workflows = parse_workflows(w.lines());

    let result_1 = run(v.lines(), &workflows);
    let result_2 = 0;

    println!(
        "Part 1: {}, Part 2: {}, took {:#?}",
        result_1,
        result_2,
        now.elapsed()
    );
}

/// FORMAT: px{a<2006:qkq,m>2090:A,rfg}
///
fn parse_workflows(lines: std::str::Lines) -> HashMap<u32, Workflow> {
    let mut map = HashMap::new();

    for l in lines {
        let bytes = l.as_bytes();

        let mut wf = Workflow {
            conditionals: [Conditional {
                var_idx: 0,
                thresholds: (0, 0),
                dest: 0,
            }; 4],
            num_conditionals: 0,
            else_dest: 0,
        };

        let mut i = 0;
        while bytes[i] != b'{' {
            i += 1;
        }
        let id = encode_name(&bytes[0..i]);
        i += 1;

        loop {
            if bytes.len() - i > 4 {
                let (cond, skip) = parse_conditional(&l[i..]);
                wf.conditionals[wf.num_conditionals] = cond;
                wf.num_conditionals += 1;
                i += skip;
            } else {
                let dst = &bytes[i..bytes.len() - 1];
                wf.else_dest = encode_name(dst);
                map.insert(id, wf);
                break;
            }
        }
    }

    map
}

/// FORMAT: a<2006:qkq,
///
fn parse_conditional(l: &str) -> (Conditional, usize) {
    let mut i = 0;
    let bytes = l.as_bytes();

    let var_idx = var_to_idx(bytes[i]);
    i += 1;

    let op = bytes[i];
    i += 1;

    let mut j = i;
    while bytes[j] != b':' {
        j += 1;
    }
    let val = l[i..j].parse::<u16>().unwrap();
    i = j + 1;

    let thresholds = match op {
        b'>' => (val, u16::MAX),
        b'<' => (0, val),
        _ => unreachable!(),
    };

    j = i;
    while bytes[j] != b',' {
        j += 1;
    }
    let dest = encode_name(&bytes[i..j]);
    i = j + 1;

    (
        Conditional {
            var_idx,
            thresholds,
            dest,
        },
        i,
    )
}

/// FORMAT: {x=787,m=2655,a=1222,s=2876}
///
fn parse_values(l: &str) -> Vec<u16> {
    let mut vals = vec![0; 4];

    for group in l[1..l.len() - 1].split(',') {
        let (var, val) = group.split_once('=').unwrap();
        vals[var_to_idx(var.as_bytes()[0])] = val.parse().unwrap();
    }

    vals
}

/// Run the workflows for each line
///
fn run(lines: std::str::Lines, workflows: &HashMap<u32, Workflow>) -> usize {
    let mut sum = 0;

    let in_id = encode_name("in".as_bytes());
    let accept_id = encode_name("A".as_bytes());
    let reject_id = encode_name("R".as_bytes());

    for l in lines {
        let mut next_wf_id = in_id;
        let values = parse_values(l);
        loop {
            let wf = workflows.get(&next_wf_id).unwrap();
            next_wf_id = wf.run(&values);

            if next_wf_id == accept_id {
                sum += values.iter().map(|&v| v as usize).sum::<usize>();
                break;
            }

            if next_wf_id == reject_id {
                break;
            }
        }
    }

    sum
}

/// It's easier to store ints that strings in rust so just pack the max 3 letter workflow name
/// into a u32
///
fn encode_name(n: &[u8]) -> u32 {
    let mut x = 0;

    for (i, &b) in n.iter().enumerate() {
        x |= (b as u32) << (8 * i);
    }

    x
}

/// Convert to an index so we can lookup easier
///
fn var_to_idx(var: u8) -> usize {
    match var {
        b'x' => 0,
        b'm' => 1,
        b'a' => 2,
        b's' => 3,
        _ => unreachable!(),
    }
}
