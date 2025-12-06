const std = @import("std");

const input_file = @embedFile("input_day6.txt");

/// Advent of code - Day 6
///
/// Part 1 - Column sums and multiplies
/// Part 2 - ???
///
pub fn main() !void {
    const timer = std.time.Timer;
    var t = try timer.start();

    const result_1 = try part1(input_file[0..]);
    const result_2 = 0;
    const duration: f64 = @floatFromInt(t.read());
    std.debug.print("Part 1: {}, Part 2: {} ms: {d:.5}\n", .{ result_1, result_2, duration / 1000000.0 });
}

/// Rather than trying to reverse, because the operator is at the bottom of the column we just
/// do parallel tracks with mul and add and then decide which to take once we hit the operator
fn part1(data: []const u8) !u64 {
    var adds = [_]u64{0} ** 3000;
    var muls = [_]u64{1} ** 3000;

    var total_add: u64 = 0;
    var total_mul: u64 = 0;

    var line_it = std.mem.tokenizeAny(u8, data, "\n");
    while (line_it.next()) |line| {
        var col_idx: usize = 0;
        var col_it = std.mem.tokenizeAny(u8, line, " ");
        while (col_it.next()) |col| {
            if (col[0] == '+') {
                total_add += adds[col_idx];
            } else if (col[0] == '*') {
                total_mul += muls[col_idx];
            } else {
                const val = try std.fmt.parseInt(u64, col, 10);
                adds[col_idx] += val;
                muls[col_idx] *= val;
            }
            col_idx += 1;
        }
    }

    return total_add + total_mul;
}
