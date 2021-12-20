const std = @import("std");
const io = std.io;
const fs = std.fs;

/// Advent of code - Day 7
///
/// Part 1 - Find the shortest distance to move each number so that they are all the same
/// Part 2 - Same as part 1 but each move costs one more than the last
///
pub fn main() !void {
    const input_file = try fs.cwd().openFile("input.txt", .{});
    defer input_file.close();

    //Using my knowledge of the file size and length to define the buffer sizes
    var input_buffer: [1024 * 5]u8 = undefined;
    const input_len = try input_file.readAll(&input_buffer);

    const stdout = std.io.getStdOut().writer();
    const timer = std.time.Timer;

    const t = try timer.start();

    //Parse the crab horizontal positions
    var vals_it = std.mem.split(input_buffer[0..input_len], ",");
    var vals = std.ArrayList(u32).init(std.heap.page_allocator);
    defer vals.deinit();

    while (vals_it.next()) |v| {
        try vals.append(try std.fmt.parseUnsigned(u32, v, 10));
    }
    std.sort.sort(u32, vals.items, {}, comptime std.sort.asc(u32));

    const result_1 = shortest_moves_1_fuel_per_move(vals.items);
    const result_2 = shortest_moves_gauss_fuel_per_move(vals.items);
    try stdout.print("Part 1: {}, Part 2: {} ms: {}\n", .{ result_1, result_2, @intToFloat(f64, t.read()) / 1000000.0 });
}

fn shortest_moves_1_fuel_per_move(vals: []u32) u32 {
    //Find the median and then sum the distance between each value and the median
    const median = vals[vals.len / 2];

    var moves_sum: u32 = 0;
    for (vals) |v| {
        const d = if (v > median) v - median else median - v;
        moves_sum += d;
    }

    return moves_sum;
}

/// The mean is within 0.5 of the actual answer so need to check floor and ceil and pick the lowest
fn shortest_moves_gauss_fuel_per_move(vals: []u32) u32 {
    var sum: u32 = 0;
    for (vals) |v| {
        sum += v;
    }

    const count = @intToFloat(f32, vals.len);
    const mean = @intToFloat(f32, sum) / count;
    const mean_f = @floatToInt(u32, @floor(mean));
    const mean_c = @floatToInt(u32, @ceil(mean));

    var moves_sum_f: u32 = 0;
    var moves_sum_c: u32 = 0;
    for (vals) |v| {
        const d_f = if (v > mean_f) v - mean_f else mean_f - v;
        moves_sum_f += (d_f * (d_f + 1)) / 2; //Triangular or Gauss sum 0, 1, 3, 6, 10

        const d_c = if (v > mean_c) v - mean_c else mean_c - v;
        moves_sum_c += (d_c * (d_c + 1)) / 2;
    }

    return std.math.min(moves_sum_c, moves_sum_f);
}
