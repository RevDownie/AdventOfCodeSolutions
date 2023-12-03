const std = @import("std");

const input_file = @embedFile("input.txt");

/// Advent of code - Day 3
///
/// Part 1 - Sum all numbers adjacent to a symbol
/// Part 2 - Sum the adjacent numbers for any '*' with exactly 2 adjacent numbers
///
pub fn main() !void {
    const timer = std.time.Timer;
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    var t = try timer.start();

    const width = findWidth(input_file[0..]);
    const result_1 = try part1(input_file[0..], width, gpa.allocator());
    const result_2 = try part2(input_file[0..], width, gpa.allocator());
    const duration: f64 = @floatFromInt(t.read());
    std.debug.print("Part 1: {}, Part 2: {} ms: {d:.5}\n", .{ result_1, result_2, duration / 1000000.0 });
}

/// Input is a grid - find a non period symbol and then check all adjacent for digits and sum any.
/// remember and account for the newline char in the data
///
fn part1(data: []const u8, width: isize, allocator: std.mem.Allocator) !u32 {
    var total: u32 = 0;

    var searched_idxs = try std.DynamicBitSet.initEmpty(allocator, data.len);
    defer searched_idxs.deinit();

    const steps = [8]isize{ 1, -1, -(width + 1), width + 1, -(width + 2), -width, width, width + 2 };

    var i: usize = 0;
    while (i < data.len) : (i += 1) {
        if (isSymbol(data[i]) == true) {
            var sig_i: isize = @intCast(i);
            for (steps) |step| {
                if (trySearch(data, sig_i, step, &searched_idxs)) |v| {
                    total += v;
                }
            }
        }
    }

    return total;
}

/// Input is a grid - find a '*' symbol and then check all adjacent for digits and if it has 2 numbers sum them.
/// This time we don't check for already visited adjacent symbols across the board - just for each symbol
/// remember and account for the newline char in the data
///
fn part2(data: []const u8, width: isize, allocator: std.mem.Allocator) !u32 {
    var total: u32 = 0;

    const steps = [8]isize{ 1, -1, -(width + 1), width + 1, -(width + 2), -width, width, width + 2 };

    var i: usize = 0;
    outer: while (i < data.len) : (i += 1) {
        if (data[i] == '*') {
            var sig_i: isize = @intCast(i);
            var sym_mul: u32 = 1;
            var adj_count: u32 = 0;

            var searched_idxs = try std.DynamicBitSet.initEmpty(allocator, data.len);
            defer searched_idxs.deinit();

            for (steps) |step| {
                if (trySearch(data, sig_i, step, &searched_idxs)) |v| {
                    adj_count += 1;
                    if (adj_count > 2) {
                        //Too many adjacent numbers - just bail early
                        continue :outer;
                    }
                    sym_mul *= v;
                }
            }

            if (adj_count == 2) {
                total += sym_mul;
            }
        }
    }

    return total;
}

/// For the given index and given adjacent step check for a digit and then parse and return the entire number that 
/// the digit is embedded in
///
fn trySearch(data: []const u8, i: isize, step: isize, searched_idxs: *std.DynamicBitSet) ?u32 {
    var new_sig_i = i + step;
    if (new_sig_i < 0 or new_sig_i >= data.len) {
        return null;
    }

    if (isDigit(data[@intCast(new_sig_i)]) == false) {
        return null;
    }

    //Find the left most digit
    while (new_sig_i >= 0 and isDigit(data[@intCast(new_sig_i)])) : (new_sig_i -= 1) {}
    const new_i: usize = @intCast(new_sig_i + 1);

    //Find the right most digit
    var end_i = new_i;
    while (isDigit(data[end_i])) : (end_i += 1) {}

    if (searched_idxs.isSet(new_i) == false) {
        searched_idxs.set(new_i);
        return std.fmt.parseInt(u32, data[new_i..end_i], 10) catch null;
    }

    return null;
}

inline fn isSymbol(char: u8) bool {
    return char != '.' and char != '\n' and isDigit(char) == false;
}

inline fn isDigit(char: u8) bool {
    return char >= '0' and char <= '9';
}

inline fn findWidth(data: []const u8) isize {
    var i: usize = 0;
    while (data[i] != '\n') : (i += 1) {}
    return @intCast(i);
}
