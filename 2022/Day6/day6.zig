const std = @import("std");

const input_file = @embedFile("input.txt");

/// Advent of code - Day 6
///
/// Part 1 - Find the index of the end of 4 consecutive different characters in a stream of data
/// Part 2 - As part 1 but 14 distinct characters
///
pub fn main() !void {
    const timer = std.time.Timer;
    var t = try timer.start();

    const result_1 = findStartOfPacketMarker(input_file[0..], 4);
    const result_2 = findStartOfPacketMarker(input_file[0..], 14);

    std.debug.print("Part 1: {}, Part 2: {} ms: {}\n", .{ result_1, result_2, @intToFloat(f64, t.read()) / 1000000.0 });
}

/// Look through the data in a sliding window of N characters until we find N unique characters
/// and return the index+1 of the last character in the sequence
/// data is all lowercase letters
///
fn findStartOfPacketMarker(data: []const u8, comptime window_size: usize) usize {
    var i: usize = 0;
    while (i < data.len) : (i += 1) {
        const window = data[i..(i + window_size)];
        var window_set = std.StaticBitSet(26).initEmpty();
        var dupe_found = false;
        for (window) |c| {
            const char_idx = c - 'a';
            if (window_set.isSet(char_idx) == true) {
                dupe_found = true;
                break;
            }
            window_set.set(char_idx);
        }

        if (dupe_found == false) {
            return i + window_size;
        }
    }

    unreachable;
}
