const std = @import("std");

const input_file = @embedFile("input.txt");

/// Advent of code - Day 6
///
/// Part 1 - You charge up a boat for x milliseconds and it goes at y speed - find all the moves that would beat the current best time
/// Part 2 - As part 1 but a single really long race
///
pub fn main() !void {
    const timer = std.time.Timer;

    var t = try timer.start();

    const result_1 = try part1(input_file[0..]);
    const result_2 = part2(input_file[0..]);

    const duration: f64 = @floatFromInt(t.read());
    std.debug.print("Part 1: {}, Part 2: {} ms: {d:.5}\n", .{ result_1, result_2, duration / 1000000.0 });
}

/// Calculate the number of different ways we could beat the record balancing time spent building up speed vs time moving
///
/// Time:      7  15   30
/// Distance:  9  40  200
///
fn part1(data: []const u8) !u64 {
    var line_it = std.mem.tokenize(u8, data, "\n");

    var times: [4]u64 = undefined;
    const time_line = line_it.next() orelse @panic("Missing times");
    var times_it = std.mem.tokenize(u8, time_line, " ");
    _ = times_it.next(); //Skip label
    for (&times) |*t| {
        t.* = try std.fmt.parseInt(u64, times_it.next() orelse @panic("Missing times"), 10);
    }

    var dists: [4]u64 = undefined;
    const dist_line = line_it.next() orelse @panic("Missing distances");
    var dists_it = std.mem.tokenize(u8, dist_line, " ");
    _ = dists_it.next(); //Skip label
    for (&dists) |*d| {
        d.* = try std.fmt.parseInt(u64, dists_it.next() orelse @panic("Missing distances"), 10);
    }

    var product: u64 = 1;
    for (times, dists) |t, d| {
        product *= solveQuadratic(t, d);
    }

    return product;
}

/// Calculate the number of different ways we could beat the record balancing time spent building up speed vs time moving. 
/// This time for a single large race so the numbers are not space delimited but a single large number
/// e.g. Time 7 15 30 => 71530
///
fn part2(data: []const u8) u64 {
    var line_it = std.mem.tokenize(u8, data, "\n");

    const time_line = line_it.next() orelse @panic("Missing times");
    var i: usize = time_line.len - 1;
    var c: u64 = 1;
    var t: u64 = 0;
    while (time_line[i] != ':') {
        if (isDigit(time_line[i]) == true) {
            t += (time_line[i] - '0') * c;
            c *= 10;
        }
        i -= 1;
    }

    const dist_line = line_it.next() orelse @panic("Missing distances");
    i = dist_line.len - 1;
    c = 1;
    var d: u64 = 0;
    while (dist_line[i] != ':') {
        if (isDigit(dist_line[i]) == true) {
            d += (dist_line[i] - '0') * c;
            c *= 10;
        }
        i -= 1;
    }

    return solveQuadratic(t, d);
}

/// Holding time (h) => h * (t - h). 
/// Expand the above and then distance needs to be greater than the original d =>  -h^2 + th - d > 0.
/// Use Quadratic Equations => (t +- √t^2 - 4*d) / 2 < h 
///
inline fn solveQuadratic(t: u64, d: u64) u64 {
    const tf: f64 = @floatFromInt(t);
    const df: f64 = @floatFromInt(d);

    const root = @sqrt(tf * tf - 4.0 * df);
    const upper = (tf + root) / 2.0;
    const lower = (tf - root) / 2.0;

    return @intFromFloat(@ceil(upper) - @floor(lower) - 1.0);
}

inline fn isDigit(char: u8) bool {
    return char >= '0' and char <= '9';
}
