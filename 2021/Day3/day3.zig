const std = @import("std");
const io = std.io;
const fs = std.fs;

/// Advent of code - Day 3
///
/// Part 1 - Build a binary number by taking the most common bit value for each bit and least common bit value for each bit and then multiply
/// part 2 - Filter out the binary numbers based on most/least common bit values
///
pub fn main() !void {
    const input_file = try fs.cwd().openFile("input.txt", .{});
    defer input_file.close();

    //Using my knowledge of the file size and length to define the buffer sizes
    var input_buffer: [1024 * 13]u8 = undefined;
    const input_len = try input_file.readAll(&input_buffer);

    const stdout = std.io.getStdOut().writer();
    const timer = std.time.Timer;

    const t = try timer.start();
    const result_1 = calculate_power_consumption(input_buffer[0..input_len], 1000);
    const result_2 = calculate_life_support_rating(input_buffer[0..input_len], 1000);

    try stdout.print("Part 1: {}, Part 2: {} ms: {}\n", .{ result_1, result_2, @intToFloat(f64, t.read()) / 1000000.0 });
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
fn calculate_life_support_rating(input_buffer: []u8, num_entries: u32) !u32 {
    const allocator = std.heap.page_allocator;
    var index_buffer = try allocator.alloc(u32, num_entries);
    defer allocator.free(index_buffer);

    const num_bits = 12;

    const o2_gen_rating = calculate_rating(input_buffer, index_buffer, num_entries, num_bits, 1, 0);
    const co2_scrub_rating = calculate_rating(input_buffer, index_buffer, num_entries, num_bits, 0, 1);
    return o2_gen_rating * co2_scrub_rating;
}

fn calculate_rating(input_buffer: []u8, index_buffer: []u32, num_entries: u32, num_bits: u32, bit_criteria_m: u8, bit_criteria_l: u8) u32 {
    //Init the index buffer which holds indices to the start of each binary sequence in the input buffer
    var i: u32 = 0;
    while (i < num_entries) : (i += 1) {
        index_buffer[i] = i * (num_bits + 1);
    }

    //Filter out indices from the index buffer based on the most/least common bit values
    var remaining: u32 = num_entries;
    var col: u32 = 0;
    while (remaining > 1) {
        //Count the number of 1s in the column
        var count: u32 = 0;
        i = 0;
        while (i < remaining) : (i += 1) {
            const index = index_buffer[i];
            count += input_buffer[index + col] - '0';
        }

        const threshold = remaining - count;
        const most_common: u8 = if (count >= threshold) bit_criteria_m else bit_criteria_l;
        i = 0;
        while (i < remaining) {
            const index = index_buffer[i];
            const bit = input_buffer[index + col] - '0';
            if (bit != most_common) {
                //Swap it out from the remaining
                remaining -= 1;
                index_buffer[i] = index_buffer[remaining];
            } else {
                i += 1;
            }
        }

        col += 1;
    }

    const rating = chars_to_decimal(input_buffer, index_buffer[0], @truncate(u5, num_bits));
    return rating;
}

fn chars_to_decimal(input_buffer: []u8, index: u32, num_bits: u5) u32 {
    var val: u32 = 0;
    var i: u5 = 0;
    while (i < num_bits) : (i += 1) {
        const idx: u5 = num_bits - i - 1; //Zig only allows shifting with consts or a << b where b is Log2(a)
        val |= @as(u32, input_buffer[index + i] - '0') << idx;
    }

    return val & 0xFFF;
}
