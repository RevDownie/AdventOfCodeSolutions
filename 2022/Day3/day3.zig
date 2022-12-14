const std = @import("std");

const ascii_offset: u8 = 6; //A-Z and a-z are not contiguous in ASCII there are 6 other symbols between them
const LetterSet = std.StaticBitSet(52 + ascii_offset);

const input_file = @embedFile("input.txt");

/// Advent of code - Day 3
///
/// Part 1 - Find the duplicate letter in a sequence and assign it a score based on the alphabet index. Sum for all input
/// Part 2 - Find the common letter in each set of three lines and assign it a score based on the alphabet index and sum all
///
pub fn main() !void {
    const timer = std.time.Timer;
    var t = try timer.start();

    const result_1 = part1(input_file[0..]);
    const result_2 = part2(input_file[0..]);
    std.debug.print("Part 1: {}, Part 2: {} ms: {d:.5}\n", .{ result_1, result_2, @intToFloat(f64, t.read()) / 1000000.0 });
}

/// Find the duplicate letter in the 2 halfs of each sequence and then return the score a-z => 1-26 A-Z => 27-52
///
fn part1(data: []const u8) usize {
    var total_score: usize = 0;

    var i: usize = 0;
    outer: while (i < data.len) {
        //Find the length of this rucksack
        var j: usize = i + 1;
        while (data[j] != '\n') : (j += 1) {}
        const rucksack = data[i..(j - 1)];
        i = j + 1;

        //Set which letters are used in the first compartment
        var compartment_1_set = LetterSet.initEmpty();
        const compartment_len = rucksack.len / 2;
        for (rucksack[0..compartment_len]) |item| {
            const idx = item - 'A';
            compartment_1_set.set(idx);
        }

        //Check if any of the second compartment letters have already been used and add their priority to the total
        for (rucksack[compartment_len..]) |item| {
            const idx = item - 'A';
            if (compartment_1_set.isSet(idx)) {
                const offset = if (idx < 26) 0 else ascii_offset;
                const contig_idx = idx - offset;
                const priority = ((contig_idx + 26) % 52) + 1; //In ASCII A comes before a, but our scoring is the other way around
                total_score += priority;
                continue :outer;
            }
        }
    }

    return total_score;
}

/// Find the single shared letter in each group of three rucksacks. Convert to the alphabet index same as part one and sum for each group
/// of three
///
fn part2(data: []const u8) usize {
    var total_score: usize = 0;

    var sets = [_]LetterSet{LetterSet.initEmpty()} ** 3;
    var set_idx: usize = 0;

    var i: usize = 0;
    while (i < data.len) {
        //Find the length of this rucksack
        var j: usize = i + 1;
        while (data[j] != '\n') : (j += 1) {}
        const rucksack = data[i..(j - 1)];
        i = j + 1;

        //Build a set of the used letters...
        for (rucksack[0..]) |item| {
            const idx = item - 'A';
            sets[set_idx].set(idx);
        }

        //...once we have 3 sets we find the shared letter
        if (set_idx == 2) {
            sets[0].setIntersection(sets[1]);
            sets[0].setIntersection(sets[2]);
            const idx = sets[0].findFirstSet().?;
            const offset = if (idx < 26) 0 else ascii_offset;
            const contig_idx = idx - offset;
            const priority = ((contig_idx + 26) % 52) + 1; //In ASCII A comes before a, but our scoring is the other way around
            total_score += priority;

            //Reset for the next group of three
            set_idx = 0;
            sets = [_]LetterSet{LetterSet.initEmpty()} ** 3;
        } else {
            set_idx += 1;
        }
    }

    return total_score;
}
