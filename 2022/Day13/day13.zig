const std = @import("std");

const input_file = @embedFile("input.txt");

const Token = struct {
    const Type = enum(i8) {
        number = 0,
        list_begin = 1,
        list_end = 2,
    };
    type: Type,
    num: u32,
    end_idx: usize,
};

/// Advent of code - Day 13
///
/// Part 1 - Matching pairs to make sure that they are in the right order e.g. [1, 2] and [1, 3] right [1, 2] and [2, 1] wrong
/// Part 2 - Find the index in a sorted list of 2 additional pairs
///
pub fn main() !void {
    const timer = std.time.Timer;
    var t = try timer.start();

    var result_1: u32 = undefined;
    var result_2: u32 = undefined;
    try run(input_file[0..], &result_1, &result_2);

    std.debug.print("Part 1: {}, Part 2: {} ms: {}\n", .{ result_1, result_2, @intToFloat(f64, t.read()) / 1000000.0 });
}

/// Sum the 1 based index of pairs that are in the right order, to be in the right order
/// left must be less than right
///
/// [[1],[2,3,4]]
/// [[1],4]
///
/// Rules:
/// => If comparisons are the same continue
/// => If left is less than right, stop, that pair is in order
/// => If right is less than left, stop, that pair is out of order
/// => Recurse into brackets (list)
/// => If one of the pairs is a list and the other is just a number - convert the number to a list
/// => Sum the index of all the pairs that are in order (1 based index)
///
/// For Part 1 we just parse and tokenise as we go
/// For Part 2 rather than sorting just compare the divisers against each line as we go
///
fn run(data: []const u8, sum_of_ordered_pairs: *u32, multiple_of_dividers: *u32) !void {
    var total: u32 = 0;
    var dec_1: u32 = 1;
    var dec_2: u32 = 2;

    var line_it = std.mem.tokenize(u8, data, "\n");
    var pair_idx: u32 = 0;
    while (line_it.next()) |line_1| {
        const line_2 = line_it.next().?;

        const result = try compare(line_1, line_2);
        if (result == std.math.Order.lt) {
            total += pair_idx + 1;
        }

        const r1 = try compare(line_1, "[[2]]");
        if (r1 == std.math.Order.lt) {
            dec_1 += 1;
        }
        const r2 = try compare(line_2, "[[2]]");
        if (r2 == std.math.Order.lt) {
            dec_1 += 1;
        }
        const r3 = try compare(line_1, "[[6]]");
        if (r3 == std.math.Order.lt) {
            dec_2 += 1;
        }
        const r4 = try compare(line_2, "[[6]]");
        if (r4 == std.math.Order.lt) {
            dec_2 += 1;
        }

        pair_idx += 1;
    }

    sum_of_ordered_pairs.* = total;
    multiple_of_dividers.* = dec_1 * dec_2;
}

/// Determine whether the left list is lower than the right
/// Recurses into sub lists
/// Handles the missing brackets case by converting to brackets
///
fn compare(left: []const u8, right: []const u8) !std.math.Order {
    var buffer: [256]u8 = undefined;

    var l = left;
    var r = right;

    while (true) {
        const token_1_opt = try parseToken(l);
        if (token_1_opt == null) {
            return std.math.Order.lt;
        }

        const token_2_opt = try parseToken(r);
        if (token_2_opt == null) {
            return std.math.Order.gt;
        }

        const token_1 = token_1_opt.?;
        const token_2 = token_2_opt.?;

        //Move past this token for the next recursion
        l = l[token_1.end_idx..];
        r = r[token_2.end_idx..];

        if (token_1.type == token_2.type and token_1.num == token_2.num) {
            //recurse
            continue;
        }

        if (token_1.type == Token.Type.number and token_2.type == Token.Type.number) {
            if (token_1.num < token_2.num) {
                return std.math.Order.lt;
            }
            if (token_1.num > token_2.num) {
                return std.math.Order.gt;
            }
            unreachable;
        }

        if (token_1.type == Token.Type.number and token_2.type == Token.Type.list_begin) {
            //Pad out 1
            var pad = try std.fmt.bufPrint(&buffer, "{}]{s}", .{ token_1.num, l });
            return compare(pad, r);
        }

        if (token_2.type == Token.Type.number and token_1.type == Token.Type.list_begin) {
            //Pad out 2
            var pad = try std.fmt.bufPrint(&buffer, "{}]{s}", .{ token_2.num, r });
            return compare(l, pad);
        }

        const delta = @enumToInt(token_2.type) - @enumToInt(token_1.type);
        if (delta < 0) {
            return std.math.Order.lt;
        }

        if (delta > 0) {
            return std.math.Order.gt;
        }

        @panic("Something has gone wrong in parsing");
    }

    @panic("Something has gone wrong in parsing");
}

/// Take the remainder of the line and parse the next token (brackets or numbers - skip commas)
/// returns the pos where the token ends in the line
///
fn parseToken(line: []const u8) !?Token {
    //std.debug.print("parseToken: {s}\n", .{line});
    if (line.len == 0) {
        return null;
    }

    var pos: usize = 0;
    if (line[pos] == ',') {
        pos += 1;
    }

    if (line[pos] == '[') {
        return Token{ .type = Token.Type.list_begin, .num = 0, .end_idx = pos + 1 };
    }

    if (line[pos] == ']') {
        return Token{ .type = Token.Type.list_end, .num = 0, .end_idx = pos + 1 };
    }

    if (isDigit(line[pos])) {
        var end_idx: usize = 0;
        const num = try parseNumber(line[pos..], &end_idx);
        return Token{ .type = Token.Type.number, .num = num, .end_idx = end_idx };
    }

    unreachable;
}

/// Return true if it is an ASCII digit between 0-9
///
inline fn isDigit(c: u8) bool {
    return c >= '0' and c <= '9';
}

/// Iterate until we get to the end of the number
///
inline fn parseNumber(line: []const u8, cursor: *usize) !u32 {
    var end: usize = 1;
    while (isDigit(line[end])) : (end += 1) {}
    cursor.* += end;
    return try std.fmt.parseUnsigned(u32, line[0..end], 10);
}
