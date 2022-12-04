const std = @import("std");

const input_file = @embedFile("input.txt");

/// Advent of code - Day 4
///
/// Part 1 - In each pai find if one of the pair's ranges entirely consumes the other
/// Part 2 - ???
///
pub fn main() !void {
    const timer = std.time.Timer;
    var t = try timer.start();

    const result_1 = try calcOverlaps(input_file[0..], entireOverlapChecker);
    const result_2 = try calcOverlaps(input_file[0..], partialOverlapChecker);
    std.debug.print("Part 1: {}, Part 2: {} ms: {}\n", .{ result_1, result_2, @intToFloat(f64, t.read()) / 1000000.0 });
}

/// Find the full overlaps for each pair e.g. 1-6 includes the range 2-4
/// Format is 2-4,6-8 with a new pair on each line. Ranges are inclusive
///
fn calcOverlaps(data: []const u8, overlap_check_fn: *const fn (a: u32, b: u32, x: u32, y: u32) bool) !usize {
    var overlap_count: usize = 0;

    var i: usize = 0;
    while (i < data.len) {
        var j: usize = i + 1;

        //Look for the end of the first number
        while (data[j] != '-') : (j += 1) {}
        const rmin_1 = try std.fmt.parseUnsigned(u32, data[i..j], 10);
        j += 2;
        i = j - 1;

        //Look for the end of the second number
        while (data[j] != ',') : (j += 1) {}
        const rmax_1 = try std.fmt.parseUnsigned(u32, data[i..j], 10);
        j += 2;
        i = j - 1;

        //Look for the end of the third number
        while (data[j] != '-') : (j += 1) {}
        const rmin_2 = try std.fmt.parseUnsigned(u32, data[i..j], 10);
        j += 2;
        i = j - 1;

        //Look for the end of the fourth number
        while (data[j] != '\n') : (j += 1) {}
        const rmax_2 = try std.fmt.parseUnsigned(u32, data[i..j], 10);
        i = j + 1;

        if (overlap_check_fn(rmin_1, rmax_1, rmin_2, rmax_2)) {
            overlap_count += 1;
        }
    }

    return overlap_count;
}

/// For Part 1, checks if the ranges overlap entirely
///
fn entireOverlapChecker(rmin_1: u32, rmax_1: u32, rmin_2: u32, rmax_2: u32) bool {
    return (rmin_1 >= rmin_2 and rmax_1 <= rmax_2) or (rmin_2 >= rmin_1 and rmax_2 <= rmax_1);
}

/// For Part 2, checks if the ranges overlap at all
///
fn partialOverlapChecker(rmin_1: u32, rmax_1: u32, rmin_2: u32, rmax_2: u32) bool {
    return (rmin_1 >= rmin_2 and rmin_1 <= rmax_2) or (rmax_1 >= rmin_2 and rmax_1 <= rmax_2) or
        (rmin_2 >= rmin_1 and rmin_2 <= rmax_1) or (rmax_2 >= rmin_1 and rmax_2 <= rmax_1);
}
