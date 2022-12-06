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
/// We don't slide the window by 1 each time as if we find a duplicate there is no point checking the rest of the window that contains
/// that dupe e.g. ABCC there is no point in check BCCD or CCDE we just slide the window to check CDEF
///
fn findStartOfPacketMarker(data: []const u8, comptime window_size: usize) usize {
    var i: usize = 0;
    while (i < data.len) : (i += 1) {
        const window = data[i..(i + window_size)];
        var window_set = [_]u8{255} ** 26; //Stored in a array rather than a bit set as we need to store the index to reduce the comparisons
        var dupe_found = false;
        for (window) |c, j| {
            const char_idx = c - 'a';
            num_checks += 1;
            if (window_set[char_idx] != 255) {
                dupe_found = true;
                i = i + window_set[char_idx]; //Skip over known duplicates
                break;
            }
            window_set[char_idx] = @intCast(u8, j);
        }

        if (dupe_found == false) {
            return i + window_size;
        }
    }

    unreachable;
}
