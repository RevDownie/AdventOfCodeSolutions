const std = @import("std");
const io = std.io;
const fs = std.fs;

/// Advent of code - Day 1
///
/// Part 1 - Count the number of increases from a list of numbers
/// Part 2 - Count the number of increases by summing a sliding window of 3
///
pub fn main() !void {
    const input_file = try fs.cwd().openFile("input.txt", .{});
    defer input_file.close();

    //Using my knowledge of the file size and length to define the buffer sizes
    var input_buffer: [1024 * 10]u8 = undefined;
    const input_len = try input_file.readAll(&input_buffer);

    var values_buffer: [2000]u32 = undefined;
    var line_it = std.mem.split(input_buffer[0..input_len], "\n");
    var line_idx: usize = 0;
    while (line_it.next()) |line| {
        values_buffer[line_idx] = try std.fmt.parseInt(u32, line, 10);
        line_idx += 1;
    }

    const result_1 = count_increases_single(values_buffer[0..line_idx]);
    const result_2 = count_increases_3window(values_buffer[0..line_idx]);

    const stdout = std.io.getStdOut().writer();
    try stdout.print("Part 1: {}, Part 2: {}\n", .{ result_1, result_2 });
}

fn count_increases_single(data: []u32) u32 {
    var prev_d: u32 = 0xFFFFFFFF;
    var count: u32 = 0;
    for (data) |next_d| {
        if (next_d > prev_d) {
            count += 1;
        }
        prev_d = next_d;
    }
    return count;
}

fn count_increases_3window(data: []u32) u32 {
    var count: u32 = 0;
    const len = data.len - 3;
    var i: usize = 0;
    while (i < len) : (i += 1) {
        const sum1 = data[i] + data[i + 1] + data[i + 2];
        const sum2 = data[i + 1] + data[i + 2] + data[i + 3];
        if (sum2 > sum1) {
            count += 1;
        }
    }
    return count;
}
