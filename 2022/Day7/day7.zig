const std = @import("std");

const input_file = @embedFile("input.txt");

const CommandType = enum {
    cd_in,
    cd_out,
    file,
    ignore,
};

const CommandData = struct {
    type: CommandType,
    file_size: usize,
};

const MAX_STACK_DEPTH = 10;
const MAX_NUM_DIRECTORIES = 500;

var next_dir_id: usize = 0;

/// Advent of code - Day 7
///
/// Part 1 - Walk directories calculating the total size of any directories that have a size of at most 100000
/// Part 2 - Find the name of the smallest directory that can be deleted to achieve our space requirements
///
pub fn main() !void {
    const timer = std.time.Timer;
    var t = try timer.start();

    const dir_sizes_map = try buildDirectorySizes(input_file[0..]);

    const result_1 = sumSizesUnderValue(dir_sizes_map[0..next_dir_id], 100000);
    const result_2 = findSmallestDirectorySizeToFreeSpace(dir_sizes_map[0..next_dir_id], 70000000, 30000000);

    std.debug.print("Part 1: {}, Part 2: {} ms: {d:.5}\n", .{ result_1, result_2, @intToFloat(f64, t.read()) / 1000000.0 });
}

/// Keep a stack of the current directories we are in
/// Each time we find a file add its size to the running total of all directories in the stack
/// Some notes:
///     * We never CD into a directory without then listing the files,
///     * Directory names aren't unique across the filesystem
///     * We don't visit a directory more than once
///     * The names of the directories play no part in either puzzle
///
fn buildDirectorySizes(data: []const u8) ![MAX_NUM_DIRECTORIES]usize {
    var dir_sizes_map: [MAX_NUM_DIRECTORIES]usize = undefined;
    var dir_stack: [MAX_STACK_DEPTH]usize = undefined;
    var dir_stack_head: usize = 0;

    var i: usize = 0;
    while (i < data.len) {
        var j: usize = i + 1;
        while (data[j] != '\n') : (j += 1) {}
        const cmd_data = try parseCommand(data[i..j]);

        switch (cmd_data.type) {
            CommandType.cd_in => {
                //Push this directory onto the stack and give it a global unique id - we will never cd into this again
                dir_sizes_map[next_dir_id] = 0;
                dir_stack[dir_stack_head] = next_dir_id;
                dir_stack_head += 1;
                next_dir_id += 1;
            },
            CommandType.cd_out => {
                //Pop the last directory off the stack
                dir_stack_head -= 1;
                dir_stack[dir_stack_head] = undefined;
            },
            CommandType.file => {
                //Add the size of this file to the running totals for all directories in the stack
                for (dir_stack[0..dir_stack_head]) |dir_id| {
                    dir_sizes_map[dir_id] += cmd_data.file_size;
                }
            },
            CommandType.ignore => {},
        }

        //Move onto the next line
        i = j + 1;
    }

    return dir_sizes_map;
}

/// Turn a line of the input into a command type and for the file command a payload with the file size
///
fn parseCommand(line: []const u8) !CommandData {
    if (line[0] == '$') {
        if (line[2] == 'c') {
            if (line[5] == '.') {
                return CommandData{ .type = CommandType.cd_out, .file_size = 0 };
            }

            return CommandData{ .type = CommandType.cd_in, .file_size = 0 };
        }
    } else if (line[0] >= '1' and line[0] <= '9') {
        var i: usize = 0;
        while (line[i] != ' ') : (i += 1) {}
        const file_size = try std.fmt.parseUnsigned(usize, line[0..i], 10);
        return CommandData{ .type = CommandType.file, .file_size = file_size };
    }

    return CommandData{ .type = CommandType.ignore, .file_size = 0 };
}

/// Iterate the file map and sum all the sizes under the limit
///
fn sumSizesUnderValue(dir_sizes_map: []const usize, comptime limit: usize) usize {
    var total: usize = 0;
    for (dir_sizes_map) |dir_size| {
        if (dir_size <= limit) {
            total += dir_size;
        }
    }
    return total;
}

/// Find the size of the smallest directory that will free up the given space
///
fn findSmallestDirectorySizeToFreeSpace(dir_sizes_map: []const usize, comptime total_capacity: usize, comptime space_required: usize) usize {
    const total_space_used = dir_sizes_map[0];
    const space_available = total_capacity - total_space_used;
    const need_to_free = space_required - space_available;

    var smallest_size: usize = total_capacity;
    for (dir_sizes_map) |dir_size| {
        if (dir_size >= need_to_free and dir_size < smallest_size) {
            smallest_size = dir_size;
        }
    }
    return smallest_size;
}
