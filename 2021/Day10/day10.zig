const std = @import("std");
const io = std.io;
const fs = std.fs;

const bracket_stack_max_size = 150;

/// Advent of code - Day 10
///
/// Part 1 - Find mismatched closing bracket types
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
    const result_2 = 0;
    try stdout.print("Part 1: {}, Part 2: {} ms: {}\n", .{ result_1, result_2, @intToFloat(f64, t.read()) / 1000000.0 });
}

/// For every line in the input find the first mismatched bracket and sum the score
/// Basically just using a stack to track pushes and pops if the closing bracket doesn't match the top 
/// of the stack then it's corrupt
///
fn calculate_corruption_score(input_buffer: []u8) !u32 {
    const BracketStack = std.SinglyLinkedList(u8);
    var bracket_stack = BracketStack{};
    var bracket_stack_node_buffer: [bracket_stack_max_size]BracketStack.Node = undefined;
    var node_head: usize = 0;

    var score: u32 = 0;

    var i: usize = 0;
    while (i < input_buffer.len) : (i += 1) {
        const c = input_buffer[i];
        if (c == '\n') {
            //Next chunk
            node_head = 0;
            bracket_stack = BracketStack{};
            continue;
        }

        if (is_open_bracket(c)) {
            bracket_stack_node_buffer[node_head] = BracketStack.Node{ .data = c };
            bracket_stack.prepend(&bracket_stack_node_buffer[node_head]);
            node_head += 1;
        } else {
            const open_bracket = bracket_stack.popFirst().?.data;
            if (get_close(open_bracket) != c) {
                score += get_score(c);
                //Skip to the end of the chunk as we are only concerned with the first mismatch on each line
                while (input_buffer[i] != '\n') : (i += 1) {}
                i -= 1; //Stop of the \n so we reset next time round the loop
            }
        }
    }

    return score;
}

fn is_open_bracket(c: u8) bool {
    return switch (c) {
        '{', '[', '(', '<' => true,
        else => false,
    };
}

fn get_close(c: u8) u8 {
    return switch (c) {
        '(' => ')',
        '[' => ']',
        '{' => '}',
        '<' => '>',
        else => unreachable,
    };
}

fn get_score(c: u8) u32 {
    return switch (c) {
        ')' => 3,
        ']' => 57,
        '}' => 1197,
        '>' => 25137,
        else => unreachable,
    };
}
