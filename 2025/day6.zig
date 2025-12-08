const std = @import("std");

const input_file = @embedFile("input_day6.txt");

/// Advent of code - Day 6
///
/// Part 1 - Column sums and multiplies
/// Part 2 - Turns out cols are right to left and transposed
///
pub fn main() !void {
    const timer = std.time.Timer;
    var t = try timer.start();

    const result_1 = try part1(input_file[0..]);
    const result_2 = try part2(input_file[0..]);
    const duration: f64 = @floatFromInt(t.read());
    std.debug.print("Part 1: {}, Part 2: {} ms: {d:.5}\n", .{ result_1, result_2, duration / 1000000.0 });
}

/// Rather than trying to reverse, because the operator is at the bottom of the column we just
/// do parallel tracks with mul and add and then decide which to take once we hit the operator
///
fn part1(data: []const u8) !u64 {
    var adds = [_]u64{0} ** 3000;
    var muls = [_]u64{1} ** 3000;

    var total: u64 = 0;

    var line_it = std.mem.tokenizeAny(u8, data, "\n");
    while (line_it.next()) |line| {
        var col_idx: usize = 0;
        var col_it = std.mem.tokenizeAny(u8, line, " ");
        while (col_it.next()) |col| {
            if (col[0] == '+') {
                total += adds[col_idx];
            } else if (col[0] == '*') {
                total += muls[col_idx];
            } else {
                const val = try std.fmt.parseInt(u64, col, 10);
                adds[col_idx] += val;
                muls[col_idx] *= val;
            }
            col_idx += 1;
        }
    }

    return total;
}

/// Similar to part 1 but we step rows rather than cols
///
fn part2(data: []const u8) !u64 {
    var total: u64 = 0;

    // Fixed line length
    const line_len = std.mem.indexOfScalar(u8, data, '\n').?;
    const line_stride = line_len + 1;

    var next_op: u8 = 0;
    var add: u64 = 0;
    var mul: u64 = 1;

    // Loop each column
    for (data[0..line_len], 0..) |_, col| {
        var next_idx = col;
        var val: u64 = 0;
        var has_digits = false;
        var op_found: u8 = 0;

        // Step down the rows for this column
        while (next_idx < data.len) : (next_idx += line_stride) {
            const c = data[next_idx];

            if (c == '+' or c == '*') {
                op_found = c;
                break;
            }

            if (c >= '0' and c <= '9') {
                has_digits = true;
                val = val * 10 + @as(u64, c - '0');
            }
        }

        if (has_digits) {
            // Accumulate in the current group
            add += val;
            mul *= val;
        } else {
            // No digits in this column position => boundary between groups - add to the overall total
            commitGroup(&total, &add, &mul, &next_op);
        }

        if (op_found != 0) {
            // This operator will apply to the *next* group we accumulate
            next_op = op_found;
        }
    }

    // Commit the last group
    commitGroup(&total, &add, &mul, &next_op);

    return total;
}

fn commitGroup(total: *u64, add: *u64, mul: *u64, next_op: *u8) void {
    // Only commit if we’ve actually seen an operator
    switch (next_op.*) {
        '+' => total.* += add.*,
        '*' => total.* += mul.*,
        else => {}, // no-op for the very first group before any operator
    }

    add.* = 0;
    mul.* = 1;
    next_op.* = 0;
}
