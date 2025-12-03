const std = @import("std");

const input_file = @embedFile("input_day3.txt");

/// Advent of code - Day 3
///
/// Part 1 - "Joltage" - Find the largest 2 digit number that can be made from the digits in order e.g. 12345 => 45, sum all these
/// Part 2 - As part one but find the largest 12 digit number
///
pub fn main() !void {
    const timer = std.time.Timer;
    var t = try timer.start();

    const result_1 = calculateMax(input_file[0..], 2);
    const result_2 = calculateMax(input_file[0..], 12);
    const duration: f64 = @floatFromInt(t.read());
    std.debug.print("Part 1: {}, Part 2: {} ms: {d:.5}\n", .{ result_1, result_2, duration / 1000000.0 });
}

/// Greedy max, find the largest number, then search the sub space after that recursively until we have all the digits we need
///
fn calculateMax(data: []const u8, comptime num_digits: u32) usize {
    var total: usize = 0;

    var line_it = std.mem.tokenizeAny(u8, data, "\n");
    while (line_it.next()) |line| {
        var start: usize = 0;
        var remaining: usize = num_digits;
        var value: usize = 0;

        while (remaining > 0) : (remaining -= 1) {
            //Adjust end to ensure we have enough digits remaining
            const end = line.len - (remaining - 1);
            const slice = line[start..end];

            const rel_idx = findIndexOfMax(slice);
            const digit = slice[rel_idx] - '0';

            value = value * 10 + digit;

            // Next search must start after the chosen digit
            start = start + rel_idx + 1;
        }

        total += value;
    }

    return total;
}

fn findIndexOfMax(slice: []const u8) usize {
    var max: u8 = 0;
    var max_idx: usize = 0;

    for (slice, 0..) |c, i| {
        if (c > max) {
            max = c;
            max_idx = i;
        }
    }

    return max_idx;
}
