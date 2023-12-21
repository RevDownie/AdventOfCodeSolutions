use std::collections::HashMap;
use std::collections::VecDeque;

const MAX_NODES: usize = 64;

struct Graph {
    types: Vec<char>,
    output_idx_map: Vec<Vec<u8>>,
    input_idx_map: Vec<Vec<u8>>,
    states: Vec<bool>,
    pulses_from: Vec<u64>,
    names: Vec<String>,
}

/// Advent of code - Day 20
///
/// Part 1 - Graph of pulses
/// Part 2 - ???
///
fn main() {
    let now = std::time::Instant::now();
    let input = std::fs::read_to_string("input.txt").unwrap();

    let (mut graph, start_idx) = parse_graph(input.lines());

    let result_1 = run(&mut graph, start_idx, 1000);
    let result_2 = 0;

    println!(
        "Part 1: {}, Part 2: {}, took {:#?}",
        result_1,
        result_2,
        now.elapsed()
    );
}

/// Parse into a graph of adjacency lists
///
fn parse_graph(lines: std::str::Lines) -> (Graph, usize) {
    let mut graph = Graph {
        types: vec!['0'; MAX_NODES],
        output_idx_map: vec![Vec::with_capacity(8); MAX_NODES],
        input_idx_map: vec![Vec::with_capacity(8); MAX_NODES],
        states: vec![false; MAX_NODES],
        pulses_from: vec![0; MAX_NODES],
        names: vec!["".to_string(); MAX_NODES],
    };

    let mut start_idx = 0;
    let mut idx_map = HashMap::new();
    let mut next_idx = 0;

    for l in lines {
        let (id, adjs_list) = l.split_once(" -> ").unwrap();
        let adjs = adjs_list.split(", ");

        let (idx, next) = get_or_insert(&id[1..], next_idx, &mut idx_map);
        next_idx = next;

        graph.names[idx as usize] = id[1..].to_string();
        graph.types[idx as usize] = id.as_bytes()[0] as char;

        for a in adjs {
            let (a_idx, next) = get_or_insert(a, next_idx, &mut idx_map);
            next_idx = next;
            graph.output_idx_map[idx as usize].push(a_idx);
            graph.input_idx_map[a_idx as usize].push(idx);
        }

        if graph.types[idx as usize] == 'b' {
            start_idx = idx as usize;
        }
    }

    (graph, start_idx)
}

/// Starting at the start index (Broadcaster), run the simulation
/// the given number of times.
/// Count the number of low and high pulses and multiply together
///
fn run(graph: &mut Graph, start_idx: usize, n_runs: usize) -> usize {
    let mut pulses_to_process = VecDeque::new();
    let mut num_low = 0;
    let mut num_high = 0;

    for _ in 0..n_runs {
        pulses_to_process.push_back((usize::MAX, start_idx, 0));
        num_low += 1;

        while let Some((f, t, p)) = pulses_to_process.pop_front() {
            let next_pulse = match graph.types[t] {
                'b' => broadcast(),
                '%' => flip_flop(t, p, graph),
                '&' => conjunction(f, t, p, graph),
                _ => None,
            };

            if let Some(np) = next_pulse {
                for i in graph.output_idx_map[t].iter() {
                    println!(
                        "SEND -> F: {}, T: {}, P: {}",
                        if t <= 64 { &graph.names[t] } else { "Button" },
                        graph.names[*i as usize],
                        if np == 1 { "H" } else { "L" }
                    );

                    pulses_to_process.push_back((t, *i as usize, np));
                    num_low += 1 - (np as usize);
                    num_high += np as usize;
                }
            }
        }
    }

    num_low * num_high
}

/// Emits a low pulse to all connected nodes
///
fn broadcast() -> Option<u8> {
    Some(0)
}

/// If it has received a low pulse it flips state and then if on sends a high pulse, otherwise sends a low
///
fn flip_flop(to_idx: usize, pulse: u8, graph: &mut Graph) -> Option<u8> {
    if pulse == 0 {
        graph.states[to_idx] = !graph.states[to_idx];

        let p = if graph.states[to_idx] { 1 } else { 0 };
        return Some(p);
    }

    None
}

/// Stores the pulses received from connected nodes - once it has high pulses from all inputs it sends
/// a low - otherwise it sends a high
///
fn conjunction(from_idx: usize, to_idx: usize, pulse: u8, graph: &mut Graph) -> Option<u8> {
    graph.pulses_from[to_idx] = if pulse == 1 {
        graph.pulses_from[to_idx] | (1_u64) << from_idx
    } else {
        graph.pulses_from[to_idx] & !((1_u64) << from_idx)
    };

    let all_hi = graph.input_idx_map[to_idx]
        .iter()
        .all(|&x| graph.pulses_from[to_idx] & (1 << x) > 0);
    let p = if all_hi { 0 } else { 1 };
    Some(p)
}

///
fn get_or_insert(id: &str, next_idx: u8, idx_map: &mut HashMap<String, u8>) -> (u8, u8) {
    match idx_map.get(id) {
        Some(idx) => (*idx, next_idx),
        None => {
            let new_idx = next_idx;
            idx_map.insert(id.to_string(), new_idx);
            (new_idx, next_idx + 1)
        }
    }
}
