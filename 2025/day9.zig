const std = @import("std");

const input_file = @embedFile("input_day9.txt");

const Vec2 = @Vector(2, i64);

/// Advent of code - Day 9
///
/// Part 1 - Find the largest rectangle by area that can be made with the coords
/// Part 2 - ???
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

/// Find distances, sort and then go through merging edges
///
fn run(data: []const u8, allocator: std.mem.Allocator) !struct { p1: u64, p2: u64 } {
    var coords = try std.ArrayList(Vec2).initCapacity(allocator, 1000);
    defer coords.deinit(allocator);

    //Parse the coords
    var line_it = std.mem.tokenizeScalar(u8, data, '\n');
    while (line_it.next()) |line| {
        var csv_it = std.mem.tokenizeScalar(u8, line, ',');
        const x = try std.fmt.parseInt(i64, csv_it.next().?, 10);
        const y = try std.fmt.parseInt(i64, csv_it.next().?, 10);
        try coords.append(allocator, Vec2{ x, y });
    }

    //Just an N^2 compute the area of each possible rect
    var max_area: u64 = 0;
    const n = coords.items.len;
    var i: usize = 0;
    while (i < n - 1) : (i += 1) {
        var j = i + 1;
        while (j < n) : (j += 1) {
            const delta = @abs(coords.items[j] - coords.items[i]) + @Vector(2, u64){ 1, 1 };
            const area = delta[0] * delta[1];
            if (area > max_area) {
                max_area = area;
            }
        }
    }

    return .{ .p1 = max_area, .p2 = 0 };
}
