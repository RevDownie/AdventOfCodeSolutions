const std = @import("std");

const input_file = @embedFile("input.txt");

/// Advent of code - Day 2
///
/// Part 1 - Parse sets of coloured balls and see if any are over the limit
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

/// Parse lines of the following "Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green"
/// a semi colon denotes the end of a set and we need to detect lines where each set can contain no more
/// than r12, g13, b14
///
fn part1(data: []const u8) !u32 {
    var total: u32 = 0;

    var line_it = std.mem.tokenize(u8, data, "\n");
    var game_id: u32 = 0;
    outer: while (line_it.next()) |line| {
        game_id += 1;

        var r: u8 = 0;
        var g: u8 = 0;
        var b: u8 = 0;

        var cursor_idx: usize = 0;
        while (line[cursor_idx] != ':') : (cursor_idx += 1) {} //Skip "Game X"
        cursor_idx += 2; //Skip ": "

        inner: while (true) {
            //Parse num
            var digit_idx = cursor_idx;
            while (isDigit(line[digit_idx])) : (digit_idx += 1) {}
            const val = try std.fmt.parseInt(u8, line[cursor_idx..digit_idx], 10);
            cursor_idx = digit_idx + 1;

            //Parse colour
            switch (line[cursor_idx]) {
                'r' => {
                    r += val;
                    cursor_idx += 3;
                },
                'g' => {
                    g += val;
                    cursor_idx += 5;
                },
                'b' => {
                    b += val;
                    cursor_idx += 4;
                },
                else => @panic("Incorrect colour start letter"),
            }

            if (r > 12 or g > 13 or b > 14) {
                //Set has too many and game is not possible
                continue :outer;
            }

            if (cursor_idx >= line.len) {
                //Game is possible
                total += game_id;
                continue :outer;
            }

            if (line[cursor_idx] == ';') {
                //End of set
                r = 0;
                g = 0;
                b = 0;
                cursor_idx += 2;
                continue :inner;
            }

            cursor_idx += 2;
        }
    }

    return total;
}

inline fn isDigit(char: u8) bool {
    return char >= '0' and char <= '9';
}
