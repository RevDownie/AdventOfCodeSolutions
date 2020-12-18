const std = @import("std");
const io = std.io;
const fs = std.fs;

const ValidationData = struct {
    min: usize, max: usize, instance: u8, psswd_start: usize
};

/// Advent of code - Day 2
///
/// Part 1 - Given a list of passwords and rules around the min/max instances of a given character that it must contain identify the number of valid passwords.
/// Part 2 - Differnt validation rules each rule provides two indices - one (oand only one) must include the specificed character
///
pub fn main() !void {
    const input_file = try fs.cwd().openFile("input.txt", .{});
    defer input_file.close();

    //Using my knowledge of the file size and length to define the buffer sizes
    var input_buffer: [20 * 1024]u8 = undefined;
    const input_len = try input_file.readAll(&input_buffer);

    var valid_count_1: usize = 0;
    var valid_count_2: usize = 0;

    var line_it = std.mem.split(input_buffer[0..input_len], "\n");
    while (line_it.next()) |line| {
        const data = try parse_line(line);

        //Rule 1 - The password must contain a number of instances of the character between min and max
        var instance_count: usize = 0;
        for (line[data.psswd_start..line.len]) |c| {
            if (c == data.instance) {
                instance_count += 1;
            }
        }

        if (instance_count >= data.min and instance_count <= data.max) {
            valid_count_1 += 1;
        }

        //Rule 2 - The password must contain a the character at either but not both of the given indices - note indexing is 1 based
        const a = line[data.psswd_start + data.min - 1] == data.instance;
        const b = line[data.psswd_start + data.max - 1] == data.instance;
        if (a != b) {
            valid_count_2 += 1;
        }
    }

    const stdout = std.io.getStdOut().writer();
    try stdout.print("Part 1: {}, Part 2: {}\n", .{ valid_count_1, valid_count_2 });
}

/// Format is mn-mx char: password e.g. 1-3 s: ssdfght
/// Parse into mn, max, char and password start
///
fn parse_line(line: []const u8) !ValidationData {

    //We know the digits are 1 or 2 characters
    const stdout = std.io.getStdOut().writer();

    //Min is followed by '-'
    const min_len: usize = if (line[1] == '-') 1 else 2;
    const min = try std.fmt.parseInt(usize, line[0..min_len], 10);

    //Max is followed by ' '
    const max_len: usize = if (line[3 + min_len - 1] == ' ') 1 else 2;
    const max_strt = min_len + 1;
    const max = try std.fmt.parseInt(usize, line[max_strt .. max_strt + max_len], 10);

    const inst_idx = max_strt + max_len + 1;
    const instance = line[inst_idx];

    const psswd_start = inst_idx + 3;

    return ValidationData{ .min = min, .max = max, .instance = instance, .psswd_start = psswd_start };
}
