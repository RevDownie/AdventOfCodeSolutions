const std = @import("std");
const io = std.io;
const fs = std.fs;

const grid_dims: u32 = 1000;
const grid_area: u32 = grid_dims * grid_dims;

/// Advent of code - Day 6
///
/// Part 1 - Lanternfish - each number ticks down when it reaches 0 it resets to 6 and spawns and 8 - count number after 80 ticks
/// Part 2 - As part 1 but with 256 ticks
///
pub fn main() !void {
    const input_file = try fs.cwd().openFile("input.txt", .{});
    defer input_file.close();

    //Using my knowledge of the file size and length to define the buffer sizes
    var input_buffer: [1024 * 10]u8 = undefined;
    const input_len = try input_file.readAll(&input_buffer);

    const stdout = std.io.getStdOut().writer();
    const timer = std.time.Timer;

    const t = try timer.start();

    const result_1 = lantern_fish(input_buffer[0..input_len], 80);
    const result_2 = lantern_fish(input_buffer[0..input_len], 256);
    try stdout.print("Part 1: {}, Part 2: {} ms: {}\n", .{ result_1, result_2, @intToFloat(f64, t.read()) / 1000000.0 });
}

fn lantern_fish(input_buffer: []u8, num_ticks: u32) !u64 {
    //Each slots holds the number of fish at the index phase of their lifecycle. When they reach zero they move to 6 and spawn a new at 8
    var num_fish_per_t = [_]u64{0} ** 9;
    var init_timer_it = std.mem.split(input_buffer[0..], ",");

    while (init_timer_it.next()) |timer| {
        num_fish_per_t[try std.fmt.parseUnsigned(usize, timer, 10)] += 1;
    }

    //Each tick is a day
    var tick: usize = 0;
    while (tick < num_ticks) : (tick += 1) {
        const num_zero_t = num_fish_per_t[0];

        var i: usize = 1;
        while (i < num_fish_per_t.len) : (i += 1) {
            //Shift the fish down the lifecycle
            num_fish_per_t[i - 1] = num_fish_per_t[i];
        }

        //The ones that have dropped off reset to 6 and spawn more at 8
        num_fish_per_t[6] += num_zero_t;
        num_fish_per_t[8] = num_zero_t;
    }

    var total_fish: u64 = 0;
    for (num_fish_per_t) |n| {
        total_fish += n;
    }
    return total_fish;
}
