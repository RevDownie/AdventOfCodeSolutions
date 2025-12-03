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

/// Maintain a stack, find the largest number, then search the sub space after that recursively until we have all the digits we need
///
fn calculateMax(data: []const u8, comptime num_digits: u32) usize {
    var total: usize = 0;
    var stack: [num_digits]usize = undefined;

    var line_it = std.mem.tokenizeAny(u8, data, "\n");
    while (line_it.next()) |line| {
        var stack_head: usize = 0;
        var start_idx: usize = 0;
        var trim: usize = stack.len;
        while (stack_head < stack.len) {
            const max_idx = findIndexOfMax(line[start_idx .. line.len - (trim - 1)]) + start_idx;
            stack[stack_head] = line[max_idx];
            stack_head += 1;
            start_idx = max_idx + 1;
            trim -= 1;
        }

        for (stack, 0..) |n, i| {
            const exp = std.math.pow(usize, 10, stack.len - i - 1);
            total += (n - '0') * exp;
        }
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
