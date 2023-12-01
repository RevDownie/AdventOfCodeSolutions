const std = @import("std");

const input_file = @embedFile("input.txt");

/// Advent of code - Day 1
///
/// Part 1 - Read the first and last digits from a line and combine
/// Part 2 - As part one but digits are spelled "one", "two", etc
///
pub fn main() !void {
    const timer = std.time.Timer;
    var t = try timer.start();

    const result_1 = part1(input_file[0..]);
    const result_2 = part2(input_file[0..]);
    const duration: f64 = @floatFromInt(t.read());
    std.debug.print("Part 1: {}, Part 2: {} ms: {d:.5}\n", .{ result_1, result_2, duration / 1000000.0 });
}

const SpelledCharResult = struct {
    value: u8,
    wordLen: usize,
};

/// Read the first and last digits from each line into a single digit and combine
/// If a line has a single digit it is used as the ten and the unit
///
fn part1(data: []const u8) u32 {
    var total: u32 = 0;

    var line_it = std.mem.tokenize(u8, data, "\n");
    while (line_it.next()) |line| {
        //Loop backward for the unit
        var bck_idx: usize = line.len - 1;
        while (bck_idx >= 0) {
            if (isDigit(line[bck_idx]) == true) {
                total += (line[bck_idx] - '0');
                break;
            }

            bck_idx -= 1;
        }

        //Loop forward for the ten
        var fwd_idx: usize = 0;
        while (fwd_idx <= bck_idx) : (fwd_idx += 1) {
            if (isDigit(line[fwd_idx]) == true) {
                total += (line[fwd_idx] - '0') * 10;
                break;
            }
        }
    }

    return total;
}

/// Worth noting that eightwo is eight and two - but they only overlap by a single letter
/// The max spelled word is 5 letters  so we don't need to check anymore than that
///
fn part2(data: []const u8) u32 {
    var total: u32 = 0;

    var line_it = std.mem.tokenize(u8, data, "\n");
    var digits: [2]u8 = undefined;

    while (line_it.next()) |line| {
        var digit_idx: usize = 0;

        var fwd_idx: usize = 0;
        while (fwd_idx < line.len) : (fwd_idx += 1) {
            if (isDigit(line[fwd_idx]) == true) {
                digits[digit_idx] = line[fwd_idx] - '0';
                if (digit_idx == 0) {
                    digits[1] = digits[digit_idx]; // Handle the case where there is only one digit found
                    digit_idx += 1;
                }
                continue;
            }

            const next_window_end = @min(fwd_idx + 5, line.len); //We slide in windows of 5 because that is the largest word len
            const converted = tryConvertSpelledDigit(line[fwd_idx..next_window_end]);
            if (converted) |c| {
                digits[digit_idx] = c.value;
                if (digit_idx == 0) {
                    digits[1] = digits[digit_idx]; // Handle the case where there is only one digit found
                    digit_idx += 1;
                }
                fwd_idx += c.wordLen - 2; //We need to substract and additional letter because of the overlap
            }
        }

        total += digits[0] * 10 + digits[1];
    }

    return total;
}

inline fn isDigit(char: u8) bool {
    return char >= '0' and char <= '9';
}

fn tryConvertSpelledDigit(chars: []const u8) ?SpelledCharResult {
    if (std.mem.startsWith(u8, chars, "zero")) {
        return SpelledCharResult{ .value = 0, .wordLen = 4 };
    }
    if (std.mem.startsWith(u8, chars, "one")) {
        return SpelledCharResult{ .value = 1, .wordLen = 3 };
    }
    if (std.mem.startsWith(u8, chars, "two")) {
        return SpelledCharResult{ .value = 2, .wordLen = 3 };
    }
    if (std.mem.startsWith(u8, chars, "three")) {
        return SpelledCharResult{ .value = 3, .wordLen = 5 };
    }
    if (std.mem.startsWith(u8, chars, "four")) {
        return SpelledCharResult{ .value = 4, .wordLen = 4 };
    }
    if (std.mem.startsWith(u8, chars, "five")) {
        return SpelledCharResult{ .value = 5, .wordLen = 4 };
    }
    if (std.mem.startsWith(u8, chars, "six")) {
        return SpelledCharResult{ .value = 6, .wordLen = 3 };
    }
    if (std.mem.startsWith(u8, chars, "seven")) {
        return SpelledCharResult{ .value = 7, .wordLen = 5 };
    }
    if (std.mem.startsWith(u8, chars, "eight")) {
        return SpelledCharResult{ .value = 8, .wordLen = 5 };
    }
    if (std.mem.startsWith(u8, chars, "nine")) {
        return SpelledCharResult{ .value = 9, .wordLen = 4 };
    }

    return null;
}
