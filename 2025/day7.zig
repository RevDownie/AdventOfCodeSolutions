const std = @import("std");

const input_file = @embedFile("input_day7.txt");

/// Advent of code - Day 7
///
/// Part 1 - Manifold splitting - count the number of times a beam is split
/// Part 2 - Many worlds - calculate the number of worlds/timelines assuming the beam only goes either left or right in each world
///
pub fn main() !void {
    const timer = std.time.Timer;
    var t = try timer.start();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const result = try run(input_file[0..], gpa.allocator());
    const duration: f64 = @floatFromInt(t.read());
    std.debug.print("Part 1: {}, Part 2: {} ms: {d:.5}\n", .{ result.p1, result.p2, duration / 1000000.0 });
}

/// Starting at 'S' split the beam on '^'. Lanternfish style
///
fn run(data: []const u8, allocator: std.mem.Allocator) !struct { p1: u64, p2: u64 } {
    var total_1: u64 = 0;

    var line_it = std.mem.tokenizeAny(u8, data, "\n");
    const first_line = line_it.next().?;

    var beams = try allocator.alloc(u64, first_line.len);
    @memset(beams, 0);
    defer allocator.free(beams);

    const start_idx = std.mem.indexOfScalar(u8, first_line, 'S').?;
    beams[start_idx] = 1;

    while (line_it.next()) |line| {
        for (line, 0..) |c, i| {
            if (beams[i] > 0 and c == '^') {
                std.debug.assert(i > 0 and i + 1 < first_line.len); //My puzzle has no '^' at bounds but adding just in case
                total_1 += 1;
                beams[i - 1] += beams[i]; //Split left
                beams[i + 1] += beams[i]; //Split right
                beams[i] = 0; //Remove the split beam
            }
        }
    }

    var total_2: u64 = 0;
    for (beams) |n| {
        total_2 += n;
    }

    return .{ .p1 = total_1, .p2 = total_2 };
}
