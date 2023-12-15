use std::collections::LinkedList;

/// Advent of code - Day 15
///
/// Part 1 - Apply HASH algorithm to strings
/// Part 2 - Process the steps and fill boxes with lenses
///
fn main() {
    let now = std::time::Instant::now();
    let input = std::fs::read_to_string("input.txt").unwrap();

    let result_1 = hash_all(input.lines().next().unwrap());
    let result_2 = run_boxing(input.lines().next().unwrap());

    println!(
        "Part 1: {}, Part 2: {}, took {:#?}",
        result_1,
        result_2,
        now.elapsed()
    );
}

/// Run our HASH algorithm on all the instruction steps in the input and sum the result
///
fn hash_all(line: &str) -> usize {
    line.split(',').map(|s| hash(s.as_bytes())).sum()
}

/// Run through the steps and fetch the label "rn=1" => "rn"
/// HASH the label to get the box number
/// Get the action (either = or -)
/// If - then look into the box and remove the lens with the label if present (making sure to close up any gaps left)
/// If = then parse the focal length "rn=1" => 1 if a lens with the same label exists in the box then replace it with the new focal length otherwise add to end of box
///
/// Then calculate the focusing power of all lenses and return
///
fn run_boxing(line: &str) -> usize {
    //256 boxes with variable number of lenses in each (order needs to be maintained)
    //Went linked list because we are adding and removing and filling gaps
    let mut boxes: Vec<LinkedList<(u64, u8)>> = Vec::with_capacity(256);
    boxes.resize(256, LinkedList::new());

    let steps = line.split(',');
    for s in steps {
        let (label, v) = s.split_once(|c| matches!(c, '-' | '=')).unwrap();
        let op = s.chars().find(|c| matches!(*c, '-' | '=')).unwrap();

        let bytes = label.as_bytes();
        let label_id = encode_label(bytes);
        let box_idx = hash(bytes);

        match op {
            '-' => { extract_if(&mut boxes[box_idx], label_id); },
            '=' => {
                let focal_len = v.parse::<u8>().unwrap();
                if let Some((_, existing_fl)) = boxes[box_idx].iter_mut().find(|l| l.0 == label_id) {
                    //Replace if exists
                    *existing_fl = focal_len;
                } else {
                    //...add if not
                    boxes[box_idx].push_back((label_id, focal_len));
                }
            }
            _ => panic!("Unknown operator"),
        }
    }

    //Calculate focusing power
    let mut power: usize = 0;
    for (box_i, lenses) in boxes.iter().enumerate() {
        for (lense_i, lense) in lenses.iter().enumerate() {
            power += (1 + box_i) * (1 + lense_i) * (lense.1 as usize);
        }
    }
    power
}

/// Apply the HASH alogrithm which performs 3 operations on each character and sums
///
fn hash(step: &[u8]) -> usize {
    let mut sum = 0;
    for &c in step {
        sum += c as usize;
        sum *= 17;
        sum %= 256;
    }

    sum
}

/// Pack the label string (max 6 chars) into a single int for easier 
/// storage and lookup
///
fn encode_label(label: &[u8]) -> u64 {
    let mut x: u64 = 0;
    for (i, &c) in label.iter().enumerate() {
        x |= (c as u64) << (8 * i);
    }

    x
}

/// The official one is only available in unstable (as is remove!)
///
fn extract_if(list: &mut LinkedList<(u64, u8)>, label_id: u64) {
    if let Some(index_to_remove) = list.iter().position(|&l| l.0 == label_id) {
        let mut split_list = list.split_off(index_to_remove);
        split_list.pop_front();
        list.append(&mut split_list);
    }
}