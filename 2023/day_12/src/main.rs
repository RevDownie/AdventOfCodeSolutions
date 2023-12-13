use std::collections::HashMap;

#[derive(PartialEq, Eq, PartialOrd, Ord, Hash)]
struct CacheKey {
    springs_1: u128,
    springs_2: u128,
    springs_3: u64,
    counts: u128,
    num_in_group: usize,
}

/// Advent of code - Day 12
///
/// Part 1 - Find all possible combinations of broken springs given partial data
/// Part 2 - As part 1 but repeat the sequences 5 times joined by a '?'
///
fn main() {
    let now = std::time::Instant::now();
    let input = std::fs::read_to_string("input.txt").unwrap();

    let (result_1, result_2) = run(input.lines());

    println!("Part 1: {}, Part 2: {}, took {:#?}", result_1, result_2, now.elapsed());
}

/// Given a sequence ???.### where '?' is unknown status, '.' is working and '#' is damaged
/// and a sequence 1,1,3 showing the number of sequential damaged. Calculate the sum of the possible resolved states of '?'
/// that support the sequential damage
///
fn run(lines: std::str::Lines) -> (usize, usize) {
    let mut sum_1: usize = 0;
    let mut sum_2: usize = 0;
    let mut cache: HashMap<CacheKey, usize> = HashMap::new();

    for line in lines {
        let (l, r) = line.split_once(' ').unwrap();
        let mut springs_1 = l.chars().collect::<Vec<char>>();
        let counts_1 = r.split(',').map(|n| n.parse::<usize>().unwrap()).collect::<Vec<usize>>();

        //Unfold - Part 2 repeats 5 times, joned with '?'
        let mut springs_2: Vec<char> = Vec::with_capacity((springs_1.len() + 1) * 5);
        let mut counts_2: Vec<usize> = Vec::with_capacity(counts_1.len() * 5);
        for _ in 0..4 {
            springs_2.extend_from_slice(&springs_1);
            springs_2.push('?');
            counts_2.extend_from_slice(&counts_1);
        }
        springs_2.extend_from_slice(&springs_1);
        counts_2.extend_from_slice(&counts_1);

        //Add this to terminate so we don't have to check for specific end case
        springs_1.push('.');
        springs_2.push('.');

        sum_1 += recurse_possibilities(&springs_1, &counts_1, 0, &mut cache);
        cache.clear();
        sum_2 += recurse_possibilities(&springs_2, &counts_2, 0, &mut cache);
        cache.clear();
    }

    (sum_1, sum_2)
}

/// Explore all possible solutions recursively. We cache already explored solutions so we don't need to recalculate (memoisation)
///
fn recurse_possibilities(springs_slice: &[char], counts: &[usize], num_in_group: usize, cache: &mut HashMap<CacheKey, usize>) -> usize {
    if springs_slice.is_empty() {
        return if counts.is_empty() && num_in_group == 0 { 1 } else { 0 };
    }

    let key = create_cache_key(springs_slice, counts, num_in_group);
    let cache_hit = cache.get(&key);
    if let Some(&x) = cache_hit {
        return x;
    }

    let mut possibilities: [char; 2] = ['0', '0'];
    let num_possibilities: usize;

    if springs_slice[0] == '?' {
        possibilities[0] = '.';
        possibilities[1] = '#';
        num_possibilities = 2;
    } else {
        possibilities[0] = springs_slice[0];
        num_possibilities = 1;
    }

    let mut sum: usize = 0;
    for p in possibilities.iter().take(num_possibilities) {
        match p {
            '.' => {
                if num_in_group > 0 {
                    if !counts.is_empty() && counts[0] == num_in_group {
                        sum += recurse_possibilities(&springs_slice[1..], &counts[1..], 0, cache);
                    }
                } else {
                    sum += recurse_possibilities(&springs_slice[1..], counts, 0, cache);
                }
            }
            '#' => sum += recurse_possibilities(&springs_slice[1..], counts, num_in_group + 1, cache),
            _ => panic!("Incorrect spring symbol"),
        }
    }

    cache.insert(key, sum);

    sum
}

/// Encode the parameters for the recurse function into a key that we can use to look up the cache
/// to find any previously calculated value
///
fn create_cache_key(springs_slice: &[char], counts: &[usize], num_in_group: usize) -> CacheKey {
    let mut key = CacheKey {
        springs_1: 0,
        springs_2: 0,
        springs_3: 0,
        counts: 0,
        num_in_group,
    };

    for (i, &s) in springs_slice.iter().enumerate() {
        let e = match s {
            '#' => 0b01,
            '.' => 0b10,
            '?' => 0b11,
            _ => panic!("Incorrect spring symbol"),
        };

        match i {
            0..=42 => key.springs_1 |= (e as u128) << (3 * i),
            43..=84 => key.springs_2 |= (e as u128) << (3 * (i - 42)),
            _ => key.springs_3 |= (e as u64) << (3 * (i - 84)),
        }
    }

    for (i, &c) in counts.iter().enumerate() {
        key.counts |= (c as u128) << (4 * i);
    }

    key
}
