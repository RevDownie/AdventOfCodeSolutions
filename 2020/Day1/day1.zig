const std = @import("std");
const io = std.io;
const fs = std.fs;

const Pair = struct {
    a: i32,
    b: i32,
};

const Triple = struct {
    a: i32,
    b: i32,
    c: i32,
};

const FindError = error{NotFound};

/// Advent of code - Day 1
///
/// Part 1 - Find the multiplication of the pair of numbers in the input file that sum to 2020
/// Part 2 - Find the multiplication of the 3 numbers that sum to 2020
///
pub fn main() !void {
    const input_file = try fs.cwd().openFile("input.txt", .{});
    defer input_file.close();

    //Using my knowledge of the file size and length to define the buffer sizes
    var input_buffer: [1024]u8 = undefined;
    const input_len = try input_file.readAll(&input_buffer);

    var values_buffer: [200]i32 = undefined;
    var line_it = std.mem.split(input_buffer[0..input_len], "\n");
    var line_idx: usize = 0;
    while (line_it.next()) |line| {
        values_buffer[line_idx] = try std.fmt.parseInt(i32, line, 10);
        line_idx += 1;
    }

    //Sort the list ascending so that when we sum values together that are bigger than 2020 we know we can move onto the next set
    var values = values_buffer[0..values_buffer.len];
    std.sort.sort(i32, values, LessCtx{}, less);

    const pair = try find_pair(values);
    const result_1 = pair.a * pair.b;

    const triple = try find_triple(values);
    const result_2 = triple.a * triple.b * triple.c;

    const stdout = std.io.getStdOut().writer();
    try stdout.print("Part 1: {}, Part 2: {}\n", .{ result_1, result_2 });
}

/// Find the pair that sums to 2020. The values are sorted low to high so while iterating
/// once we exceed 2020 we know the outer value isn't the one and can move on
///
fn find_pair(values: []const i32) !Pair {
    var i: usize = 0;
    iloop: while (i < values.len) : (i += 1) {
        var j: usize = i + 1;
        while (j < values.len) : (j += 1) {
            const sum = values[i] + values[j];
            const target_delta = sum - 2020;

            if (target_delta == 0)
                return Pair{ .a = values[i], .b = values[j] };

            if (target_delta > 0)
                continue :iloop;
        }
    }

    return error.NotFound;
}

/// Find the 3 numbers that sum to 2020. The values are sorted low to high so while iterating
/// once we exceed 2020 we know the outer value isn't the one and can move on
///
fn find_triple(values: []const i32) !Triple {
    var i: usize = 0;
    while (i < values.len) : (i += 1) {
        const remainder_to_find = 2020 - values[i];
        var j: usize = i + 1;
        jloop: while (j < values.len) : (j += 1) {
            var k: usize = j + 1;
            while (k < values.len) : (k += 1) {
                const sum = values[j] + values[k];
                const target_delta = sum - remainder_to_find;

                if (target_delta == 0)
                    return Triple{ .a = values[i], .b = values[j], .c = values[k] };

                if (target_delta > 0)
                    continue :jloop;
            }
        }
    }

    return error.NotFound;
}

/// Sort predicate to order ascending
const LessCtx = struct {};
fn less(context: LessCtx, a: i32, b: i32) bool {
    return a < b;
}
