const std = @import("std");

const input_file = @embedFile("input_day1.txt");

/// Advent of code - Day 1
///
/// Part 1 - Rotate a safe combination left and right and count the number of times it lands on zero
/// Part 2 - Count the number of times we rotate through zero
///
pub fn main() !void {
    const timer = std.time.Timer;
    var t = try timer.start();

    const result_1 = try part1(input_file[0..]);
    const result_2 = try part2(input_file[0..]);
    const duration: f64 = @floatFromInt(t.read());
    std.debug.print("Part 1: {}, Part 2: {} ms: {d:.5}\n", .{ result_1, result_2, duration / 1000000.0 });
}

/// Dial starts at 50 and goes from 0 to 99 before wrapping
/// We just care about landing on zero so we can modulo the input to avoid multiple full rotations
///
fn part1(data: []const u8) !u32 {
    var dial: i32 = 50;
    var zero_count: u32 = 0;

    var line_it = std.mem.tokenizeAny(u8, data, "\n");
    while (line_it.next()) |line| {
        const clicks = @mod(try std.fmt.parseInt(i32, line[1..], 10), 100);

        switch (line[0]) {
            'L' => dial -= clicks,
            'R' => dial += clicks,
            else => @panic("Invalid Direction"),
        }

        dial = @intCast(@mod(dial, 100));

        if (dial == 0) {
            zero_count += 1;
        }
    }

    return zero_count;
}

/// Dial starts at 50 and goes from 0 to 99 before wrapping.
/// This time we care about multiple full rotations as they will cause it to pass through 0
///
fn part2(data: []const u8) !u32 {
    var dial: i32 = 50;
    var zero_count: u32 = 0;

    var line_it = std.mem.tokenizeAny(u8, data, "\n");
    while (line_it.next()) |line| {
        const clicks = try std.fmt.parseInt(i32, line[1..], 10);
        const clicks_dir = switch (line[0]) {
            'L' => -clicks,
            'R' => clicks,
            else => @panic("Invalid Direction"),
        };

        const new_dial = dial + clicks_dir;

        if (new_dial > 0) {
            zero_count += @intCast(@divTrunc(new_dial, 100));
        } else if (new_dial == 0) {
            zero_count += 1;
        } else {
            zero_count += @intCast(@divTrunc(@mod(100 - dial, 100) + clicks, 100));
        }

        dial = @mod(new_dial, 100);
    }

    return zero_count;
}
