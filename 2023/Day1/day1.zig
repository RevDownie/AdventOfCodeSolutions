const std = @import("std");

const input_file = @embedFile("input.txt");

/// Advent of code - Day 1
///
/// Part 1 - ???
/// Part 2 - ???
///
pub fn main() !void {
    const timer = std.time.Timer;
    var t = try timer.start();

    const result_1 = 0;
    const result_2 = 0;
    const duration: f64 = @floatFromInt(t.read());
    std.debug.print("Part 1: {}, Part 2: {} ms: {d:.5}\n", .{ result_1, result_2, duration/1000000.0 });
}
