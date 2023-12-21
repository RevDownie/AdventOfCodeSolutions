use std::collections::HashMap;
use std::collections::VecDeque;

const MAX_NODES: usize = 64;

struct Graph {
    types: Vec<char>,
    output_idx_map: Vec<Vec<u8>>,
    input_idx_map: Vec<Vec<u8>>,
    states: Vec<bool>,
    pulses_from: Vec<u64>,
}

/// Advent of code - Day 20
///
/// Part 1 - Graph of pulses
/// Part 2 - Part 2 find the lowest number of button presses that would trigger RX
///
fn main() {
    let now = std::time::Instant::now();
    let input = std::fs::read_to_string("input.txt").unwrap();

    let (mut graph, start_idx, rx_idx) = parse_graph(input.lines());

    let (result_1, result_2) = run(&mut graph, start_idx, rx_idx, 1000);

    println!(
        "Part 1: {}, Part 2: {}, took {:#?}",
        result_1,
        result_2,
        now.elapsed()
    );
}

/// Parse into a graph of adjacency lists
///
fn parse_graph(lines: std::str::Lines) -> (Graph, usize, usize) {
    let mut graph = Graph {
        types: vec!['0'; MAX_NODES],
        output_idx_map: vec![Vec::with_capacity(8); MAX_NODES],
        input_idx_map: vec![Vec::with_capacity(8); MAX_NODES],
        states: vec![false; MAX_NODES],
        pulses_from: vec![0; MAX_NODES],
    };

    let mut start_idx = 0;
    let mut rx_idx = 0;
    let mut idx_map = HashMap::new();
    let mut next_idx = 0;

    for l in lines {
        let (id, adjs_list) = l.split_once(" -> ").unwrap();
        let adjs = adjs_list.split(", ");

        let (idx, next) = get_or_insert(&id[1..], next_idx, &mut idx_map);
        next_idx = next;

        graph.types[idx as usize] = id.as_bytes()[0] as char;

        for a in adjs {
            let (a_idx, next) = get_or_insert(a, next_idx, &mut idx_map);
            next_idx = next;
            graph.output_idx_map[idx as usize].push(a_idx);
            graph.input_idx_map[a_idx as usize].push(idx);

            if a == "rx" {
                rx_idx = a_idx as usize;
            }
        }

        if graph.types[idx as usize] == 'b' {
            start_idx = idx as usize;
        }
    }

    (graph, start_idx, rx_idx)
}

/// Starting at the start index (Broadcaster), run the simulation
/// the given number of times.
/// Part 1: Count the number of low and high pulses in the give number of runs and multiply together
/// Part 2: Use LCM and cyclic nature to find the min number of runs for rx to be triggered
///
fn run(graph: &mut Graph, start_idx: usize, rx_idx: usize, n_runs: usize) -> (usize, usize) {
    let mut pulses_to_process = VecDeque::new();
    let mut num_low = 0;
    let mut num_high = 0;
    let mut runs = 0;
    let mut part_1 = 0;

    //Find all connections to single conjunction model connecting to RX.
    //Find how many button presses it takes for each of them to send a high pulse which would then cause
    //it to send a low pulse to RX. Take the LCM
    let rx_feed_idx = graph.input_idx_map[rx_idx][0];
    let mut button_presses = vec![0; graph.input_idx_map[rx_feed_idx as usize].len()];

    loop {
        if runs == n_runs {
            part_1 = num_low * num_high;
        }

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
                //Are we sending a high pulse to the rx feeder?
                for (i, x) in graph.input_idx_map[rx_feed_idx as usize].iter().enumerate() {
                    if p == 1 && t == (rx_feed_idx as usize) && f == (*x as usize) {
                        button_presses[i] = runs + 1;
                        continue;
                    }
                }

                for nt in &graph.output_idx_map[t] {
                    pulses_to_process.push_back((t, *nt as usize, np));
                    num_low += 1 - (np as usize);
                    num_high += np as usize;
                }
            }
        }

        if button_presses.iter().all(|&x| x > 0) {
            let part_2 = button_presses.iter().fold(1, |acc, n| lcm(acc, *n));
            return (part_1, part_2);
        }

        runs += 1;
    }
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

/// Find the lowest common multiple of 2 numbers
///
fn lcm(a: usize, b: usize) -> usize {
    let mut max = a.max(b);
    let mut min = a.min(b);

    loop {
        let res = max % min;
        if res == 0 {
            return (a * b) / min;
        }

        max = min;
        min = res;
    }
}
