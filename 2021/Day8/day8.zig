const std = @import("std");
const io = std.io;
const fs = std.fs;

/// Advent of code - Day 8
///
/// Part 1 - Find all the numbers in the output section that correspond to 1,4,7 and 8 - i.e. have sequence length matching 2,4,3,7
///
pub fn main() !void {
    const input_file = try fs.cwd().openFile("input.txt", .{});
    defer input_file.close();

    //Using my knowledge of the file size and length to define the buffer sizes
    var input_buffer: [1024 * 17]u8 = undefined;
    const input_len = try input_file.readAll(&input_buffer);

    const stdout = std.io.getStdOut().writer();
    const timer = std.time.Timer;

    const t = try timer.start();
    const result_1 = count_uniquely_segmented_digits_in_output(input_buffer[0..input_len]);
    const result_2 = 0;
    try stdout.print("Part 1: {}, Part 2: {} ms: {}\n", .{ result_1, result_2, @intToFloat(f64, t.read()) / 1000000.0 });
}

fn count_uniquely_segmented_digits_in_output(input_buffer: []u8) !u32 {
    var total: u32 = 0;
    var i: usize = 0;
    full_loop: while (true) { //Loop over the full input

        while (input_buffer[i] != '|') : (i += 1) {} //Skip to the output
        i += 2;

        output_loop: while (true) : (i += 1) { //Loop over the output
            var seq_len: u32 = 0;
            while (input_buffer[i] != ' ' and input_buffer[i] != '\n') : (i += 1) { //Count the sequence length breaking on spaces
                seq_len += 1;
            }

            if (seq_len == 2 or seq_len == 4 or seq_len == 3 or seq_len == 7) { //Unique segments count for the digits - 1,4,7,8
                total += 1; //Sum all the "unique" digit counts
            }

            if (i >= input_buffer.len - 1) {
                break :full_loop;
            }

            if (input_buffer[i] == '\n') { //End of the line - jump to the next output
                break :output_loop;
            }
        }
    }

    return total;
}
