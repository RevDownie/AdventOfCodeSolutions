const std = @import("std");

const input_file = @embedFile("input.txt");

/// Advent of code - Day 3
///
/// Part 1 - Sum all numbers adjacent to a symbol
/// Part 2 - ???
///
pub fn main() !void {
    const timer = std.time.Timer;
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    var t = try timer.start();

    const width = findWidth(input_file[0..]);
    const result_1 = try part1(input_file[0..], width, gpa.allocator());
    const result_2 = 0;
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

    var i: usize = 0;
    while (i < data.len) : (i += 1) {
        if (isSymbol(data[i]) == true) {
            var sig_i: isize = @intCast(i);

            //Right
            if (trySearch(data, sig_i, 1, &searched_idxs)) |v| {
                total += v;
            }

            //Left
            if (trySearch(data, sig_i, -1, &searched_idxs)) |v| {
                total += v;
            }

            //Top
            if (trySearch(data, sig_i, -(width + 1), &searched_idxs)) |v| {
                total += v;
            }

            //Bottom
            if (trySearch(data, sig_i, width + 1, &searched_idxs)) |v| {
                total += v;
            }

            //TL
            if (trySearch(data, sig_i, -(width + 2), &searched_idxs)) |v| {
                total += v;
            }

            //TR
            if (trySearch(data, sig_i, -width, &searched_idxs)) |v| {
                total += v;
            }

            //BL
            if (trySearch(data, sig_i, width, &searched_idxs)) |v| {
                total += v;
            }

            //BR
            if (trySearch(data, sig_i, width + 2, &searched_idxs)) |v| {
                total += v;
            }
        }
    }

    return total;
}

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
