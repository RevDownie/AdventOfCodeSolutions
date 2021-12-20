const std = @import("std");
const io = std.io;
const fs = std.fs;

const bracket_stack_max_size = 150;

/// Advent of code - Day 10
///
/// Part 1 - Find mismatched closing bracket types
/// Part 2 - Finish incomplete bracket sequences
///
pub fn main() !void {
    const input_file = try fs.cwd().openFile("input.txt", .{});
    defer input_file.close();

    //Using my knowledge of the file size and length to define the buffer sizes
    var input_buffer: [1024 * 10]u8 = undefined;
    const input_len = try input_file.readAll(&input_buffer);

    const stdout = std.io.getStdOut().writer();
    const timer = std.time.Timer;
    const t = try timer.start();

    const result_1 = calculate_corruption_score(input_buffer[0..input_len]);
    const result_2 = calculate_completion_score(input_buffer[0..input_len]);
    try stdout.print("Part 1: {}, Part 2: {} ms: {}\n", .{ result_1, result_2, @intToFloat(f64, t.read()) / 1000000.0 });
}

/// For every line in the input find the first mismatched bracket and sum the score
/// Basically just using a stack to track pushes and pops if the closing bracket doesn't match the top 
/// of the stack then it's corrupt
///
fn calculate_corruption_score(input_buffer: []u8) !u32 {
    var bracket_stack: [bracket_stack_max_size]u8 = undefined;
    var node_head: usize = 0;

    var score: u32 = 0;

    var i: usize = 0;
    while (i < input_buffer.len) : (i += 1) {
        const c = input_buffer[i];
        if (c == '\n') {
            //Next chunk
            node_head = 0;
            continue;
        }

        if (is_open_bracket(c)) {
            //Push
            bracket_stack[node_head] = c;
            node_head += 1;
        } else {
            //Pop
            node_head -= 1;
            const open_bracket = bracket_stack[node_head];
            if (get_closing_bracket(open_bracket) != c) {
                score += get_corruption_score(c);
                //Skip to the end of the chunk as we are only concerned with the first mismatch on each line
                while (input_buffer[i] != '\n') : (i += 1) {}
                i -= 1; //Stop of the \n so we reset next time round the loop
            }
        }
    }

    return score;
}

/// Discard corrupt lines and for any incomplete lines complete the bracket sequence and calculate the score by finding the median
///
fn calculate_completion_score(input_buffer: []u8) !u64 {
    var bracket_stack: [bracket_stack_max_size]u8 = undefined;
    var node_head: usize = 0;

    var chunk_scores = std.ArrayList(u64).init(std.heap.page_allocator);
    defer chunk_scores.deinit();

    var i: usize = 0;
    while (i < input_buffer.len) : (i += 1) {
        const c = input_buffer[i];
        if (c == '\n') {
            //Next chunk - calculate the completion score from any unclosed braces
            var chunk_score: u64 = 0;
            while (node_head > 0) : (node_head -= 1) {
                const open_bracket = bracket_stack[node_head - 1];
                chunk_score = chunk_score * 5 + get_completion_score(open_bracket);
            }

            if (chunk_score > 0) {
                try chunk_scores.append(chunk_score);
            }

            continue;
        }

        if (is_open_bracket(c)) {
            bracket_stack[node_head] = c;
            node_head += 1;
        } else {
            node_head -= 1;
            const open_bracket = bracket_stack[node_head];
            if (get_closing_bracket(open_bracket) != c) {
                //Clear stack and skip to the end of the chunk as we are discarding corrupted lines
                node_head = 0;
                while (input_buffer[i] != '\n') : (i += 1) {}
                i -= 1; //Stop of the \n so we reset next time round the loop
            }
        }
    }

    //Find the median
    var scores = chunk_scores.items;
    std.sort.sort(u64, scores, {}, comptime std.sort.asc(u64));
    return scores[scores.len / 2];
}

fn is_open_bracket(c: u8) bool {
    return switch (c) {
        '{', '[', '(', '<' => true,
        else => false,
    };
}

fn get_closing_bracket(c: u8) u8 {
    return switch (c) {
        '(' => ')',
        '[' => ']',
        '{' => '}',
        '<' => '>',
        else => unreachable,
    };
}

fn get_corruption_score(c: u8) u32 {
    return switch (c) {
        ')' => 3,
        ']' => 57,
        '}' => 1197,
        '>' => 25137,
        else => unreachable,
    };
}

fn get_completion_score(c: u8) u32 {
    return switch (c) {
        '(' => 1,
        '[' => 2,
        '{' => 3,
        '<' => 4,
        else => unreachable,
    };
}
