const std = @import("std");
const io = std.io;
const fs = std.fs;

/// Advent of code - Day 2
///
/// Part 1 - Input is a series of forward and depth movements have to track them and multiply them
/// Part 2 - Up/Donw changes your aim and forward alters depth and horizontal based on aim
///
pub fn main() !void {
    const input_file = try fs.cwd().openFile("input.txt", .{});
    defer input_file.close();

    //Using my knowledge of the file size and length to define the buffer sizes
    var input_buffer: [1024 * 8]u8 = undefined;
    const input_len = try input_file.readAll(&input_buffer);

    const result_1 = calculate_position_multiplied(input_buffer[0..input_len]);
    const result_2 = calculate_aim_position_multiplied(input_buffer[0..input_len]);

    const stdout = std.io.getStdOut().writer();
    try stdout.print("Part 1: {}, Part 2: {}\n", .{ result_1, result_2 });
}

fn calculate_position_multiplied(input_buffer: []u8) u32 {
    var horizontal: u32 = 0;
    var depth: u32 = 0;

    var line_it = std.mem.split(input_buffer, "\n");

    //Note only uses single digits
    while (line_it.next()) |line| {
        if (line[0] == 'f') { //Forward
            horizontal += line[8] - '0';
        } else if (line[0] == 'd') { //Down
            depth += line[5] - '0';
        } else { // Up
            depth -= line[3] - '0';
        }
    }

    return horizontal * depth;
}

fn calculate_aim_position_multiplied(input_buffer: []u8) u32 {
    var horizontal: u32 = 0;
    var depth: u32 = 0;
    var aim: u32 = 0;

    var line_it = std.mem.split(input_buffer, "\n");

    //Note only uses single digits
    while (line_it.next()) |line| {
        if (line[0] == 'f') { //Forward
            const x = line[8] - '0';
            horizontal += x;
            depth += aim * x;
        } else if (line[0] == 'd') { //Down
            aim += line[5] - '0';
        } else { // Up
            aim -= line[3] - '0';
        }
    }

    return horizontal * depth;
}
