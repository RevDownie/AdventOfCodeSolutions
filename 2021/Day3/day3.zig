const std = @import("std");
const io = std.io;
const fs = std.fs;

/// Advent of code - Day 3
///
/// Part 1 - Build a binary number by taking the most common bit value for each bit and least common bit value for each bit and then multiply
///
pub fn main() !void {
    const input_file = try fs.cwd().openFile("input.txt", .{});
    defer input_file.close();

    //Using my knowledge of the file size and length to define the buffer sizes
    var input_buffer: [1024 * 13]u8 = undefined;
    const input_len = try input_file.readAll(&input_buffer);

    const result_1 = calculate_power_consumption(input_buffer[0..input_len], 1000);
    const result_2 = calculate_life_support_rating(input_buffer[0..input_len], 1000);

    const stdout = std.io.getStdOut().writer();
    try stdout.print("Part 1: {}, Part 2: {}\n", .{ result_1, result_2 });
}

/// For each entry which is a binary number count the number of 1s in each column and build a gamma number
/// with the most common value for each bit column. Epsilon is built from the least common and then power consumption is the multiple
///
fn calculate_power_consumption(input_buffer: []u8, num_entries: u32) u32 {
    const num_bits = 12;
    var gamma: u32 = 0;

    var counts = [_]u32{0} ** num_bits;

    var i: usize = 0;
    while (i < input_buffer.len) : (i += num_bits + 1) {
        var j: usize = 0;
        while (j < num_bits) : (j += 1) {
            counts[j] += input_buffer[i + j] - '0';
        }
    }

    var k: u5 = 0;
    const threshold = num_entries / 2;
    while (k < num_bits) : (k += 1) {
        if (counts[k] > threshold) { //There are more 1s than 0s
            const idx: u5 = num_bits - k - 1; //Zig only allows shifting with consts or a << b where b is Log2(a)
            gamma |= @as(u32, 1) << idx;
        }
    }

    const epsilon = ~gamma & 0xFFF;
    return gamma * epsilon;
}

/// Filtering out binary numbers based on the most common/least common bit values
///
fn calculate_life_support_rating(input_buffer: []u8, num_entries: u32) u64 {
    return 0;
}
