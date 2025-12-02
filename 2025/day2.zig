const std = @import("std");

const input_file = @embedFile("input_day2.txt");

/// Advent of code - Day 2
///
/// Part 1 - Sum invalid ids - Ids where the first and second halves of digits are equal e.g. 123123
/// Part 2 - Invalid ids now include any id with a repeated pattern e.g 11111, 12121212
///
pub fn main() !void {
    const timer = std.time.Timer;
    var t = try timer.start();

    const result_1 = try part1(input_file[0..]);
    const result_2 = try part2(input_file[0..]);
    const duration: f64 = @floatFromInt(t.read());
    std.debug.print("Part 1: {}, Part 2: {} ms: {d:.5}\n", .{ result_1, result_2, duration / 1000000.0 });
}

/// Skip numbers with odd number of digits and then check if first and second parts of the number are equal
///
fn part1(data: []const u8) !u64 {
    var line_it = std.mem.tokenizeAny(u8, data, "\n");
    const line = line_it.next().?;

    var total: u64 = 0;

    var csv_it = std.mem.tokenizeAny(u8, line, ",");
    while (csv_it.next()) |csv| {
        var range_it = std.mem.tokenizeScalar(u8, csv, '-');
        const min = try std.fmt.parseInt(u64, range_it.next().?, 10);
        const max = try std.fmt.parseInt(u64, range_it.next().?, 10) + 1;

        for (min..max) |n| {
            const num_digits = numDigits(n);
            if (num_digits % 2 != 0) {
                continue;
            }

            const div = std.math.pow(u64, 10, @divTrunc(num_digits, 2));
            if (@divTrunc(n, div) == n % div) {
                total += n;
            }
        }
    }

    return total;
}

/// Brute force - as part one but comparing groups of digits from 1 to n/2
///
fn part2(data: []const u8) !u64 {
    var line_it = std.mem.tokenizeAny(u8, data, "\n");
    const line = line_it.next().?;

    var total: u64 = 0;

    var csv_it = std.mem.tokenizeAny(u8, line, ",");
    while (csv_it.next()) |csv| {
        var range_it = std.mem.tokenizeScalar(u8, csv, '-');
        const min = try std.fmt.parseInt(u64, range_it.next().?, 10);
        const max = try std.fmt.parseInt(u64, range_it.next().?, 10) + 1;

        for (min..max) |n| {
            const num_digits = numDigits(n);
            const half_digits_inc = @divTrunc(num_digits, 2) + 1;

            for (1..half_digits_inc) |pattern_len| {
                if (num_digits % pattern_len != 0) {
                    continue;
                }

                const pattern = @divTrunc(n, std.math.pow(u64, 10, num_digits - pattern_len));
                const div = std.math.pow(u64, 10, pattern_len) - 1;
                const mul = std.math.pow(u64, 10, num_digits) - 1;

                if (n * div == pattern * mul) {
                    total += n;
                    break; //Need to break to avoid double dipping on repeated patterns
                }
            }
        }
    }

    return total;
}

fn numDigits(n: u64) u64 {
    if (n == 0) return 1;
    return std.math.log10(n) + 1;
}
