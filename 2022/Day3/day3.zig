const std = @import("std");

const input_file = @embedFile("input.txt");

/// Advent of code - Day 3
///
/// Part 1 - Find the duplicate letter in a sequence and assign it a score based on the alphabet index. Sum for all input
/// Part 2 - ???
///
pub fn main() !void {
    const timer = std.time.Timer;
    var t = try timer.start();

    const result_1 = part1(input_file[0..]);
    const result_2 = 0;
    std.debug.print("Part 1: {}, Part 2: {} ms: {}\n", .{ result_1, result_2, @intToFloat(f64, t.read()) / 1000000.0 });
}

/// Find the duplicate letter in the 2 halfs of each sequence and then return the score a-z => 1-26 A-Z => 27-52
///
fn part1(data: []const u8) u32 {
    var total_score: u32 = 0;

    var i: usize = 0;
    outer: while (i < data.len) {
        //Find the length of this rucksack
        var j: usize = i + 1;
        while (data[j] != '\n') : (j += 1) {}
        const rucksack = data[i..(j - 1)];
        i = j + 1;

        //Set which letters are used in the first compartment
        const ascii_offset: u8 = 6;
        var compartment_1_set = std.StaticBitSet(52 + ascii_offset).initEmpty(); //58 because A-Z and a-z are not contiguous in ASCII there are 6 other symbols between them
        const compartment_len = rucksack.len / 2;
        for (rucksack[0..compartment_len]) |item| {
            const idx = item - 'A';
            compartment_1_set.setValue(idx, true);
        }

        //Check if any of the second compartment letters have already been used and add their priority to the total
        for (rucksack[compartment_len..]) |item| {
            const idx = item - 'A';
            if (compartment_1_set.isSet(idx)) {
                const offset = if (idx < 26) 0 else ascii_offset;
                const contig_idx = idx - offset;
                const priority = ((contig_idx + 26) % 52) + 1;
                total_score += priority;
                continue :outer;
            }
        }
    }

    return total_score;
}
