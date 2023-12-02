const std = @import("std");

const input_file = @embedFile("input.txt");

const Result = struct { sum_of_possible_game_ids: u32, sum_power_of_min_cubes: u32 };

/// Advent of code - Day 2
///
/// Part 1 - Parse sets of coloured cubes and see if any are over the limit
/// Part 2 - Parse sets of coloured cubes and find the max in each set
///
pub fn main() !void {
    const timer = std.time.Timer;
    var t = try timer.start();

    const result = try run(input_file[0..]);
    const duration: f64 = @floatFromInt(t.read());
    std.debug.print("Part 1: {}, Part 2: {} ms: {d:.5}\n", .{ result.sum_of_possible_game_ids, result.sum_power_of_min_cubes, duration / 1000000.0 });
}

/// Parse lines of the following "Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green"
/// a semi colon denotes the end of a set and we need to detect lines where each set can contain no more
/// than r12, g13, b14
///
/// At the same time look for the max num of a given color as this is the min number to make that game possible
///
fn run(data: []const u8) !Result {
    var sum_of_possible_game_ids: u32 = 0;
    var sum_power_of_min_cubes: u32 = 0;

    var line_it = std.mem.tokenize(u8, data, "\n");
    var game_id: u32 = 0;
    outer: while (line_it.next()) |line| {
        game_id += 1;

        var r: u8 = 0;
        var g: u8 = 0;
        var b: u8 = 0;
        var rmx: u32 = 0;
        var gmx: u32 = 0;
        var bmx: u32 = 0;

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

            if (cursor_idx >= line.len) {
                //End of set and line
                rmx = @max(r, rmx);
                gmx = @max(g, gmx);
                bmx = @max(b, bmx);

                if (rmx <= 12 and gmx <= 13 and bmx <= 14) {
                    //Game is possible
                    sum_of_possible_game_ids += game_id;
                }

                sum_power_of_min_cubes += rmx * gmx * bmx;
                continue :outer;
            }

            if (line[cursor_idx] == ';') {
                //End of set
                rmx = @max(r, rmx);
                gmx = @max(g, gmx);
                bmx = @max(b, bmx);
                r = 0;
                g = 0;
                b = 0;
                cursor_idx += 2;
                continue :inner;
            }

            cursor_idx += 2;
        }
    }

    return Result{ .sum_of_possible_game_ids = sum_of_possible_game_ids, .sum_power_of_min_cubes = sum_power_of_min_cubes };
}

inline fn isDigit(char: u8) bool {
    return char >= '0' and char <= '9';
}
